#!/usr/bin/env python3
"""github-push preflight: the push checks that need no judgment.

    preflight.py          branch, identity, secrets in uncommitted files and unpushed commits
    preflight.py --hook   PreToolUse hook on `git push`: identity and unpushed commits only

Prints one line per check, `ok`, `warn` or `FAIL`, and exits 1 when a check fails. As a hook
it exits 0 at once for a command that doesn't push, stays silent on success, and exits 2 on
failure, which makes Claude Code block the push.
"""

import fnmatch
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HOOK = "--hook" in sys.argv[1:]
# Commits reachable from HEAD that no remote-tracking branch has: what a push can publish
UNPUSHED = ["HEAD", "--not", "--remotes"]
SECRET_FILES = [
    ".env", ".env.*", "*.pem", "*.key", "*.p12", "*.pfx", "*.jks", "*.secret", "*.secrets",
    "credentials.*", "service-account*.json", "*.keystore", "id_rsa", "id_ed25519*",
    "token.json", "tokens.json", ".npmrc", ".pypirc", "*.tfvars", ".htpasswd", ".vault_pass",
]  # fmt: skip
VAULT_FILES = ["vault*.yml", "vault*.yaml"]
# Placeholder companions such as `.env.example`, which the skill itself asks for
TEMPLATE_SUFFIXES = (".example", ".sample", ".template", ".dist")
PUSH_PERMISSIONS = {"ADMIN", "MAINTAIN", "WRITE"}
PUSH = re.compile(r"\bgit\b[^\n;&|]*\bpush\b")

results = []


def report(status, check, detail):
    results.append((status, f"{status:<4} {check}: {detail}"))


def run(*cmd, check=True):
    return subprocess.run(cmd, capture_output=True, text=True, check=check)


def check_branch():
    branch = run("git", "branch", "--show-current").stdout.strip() or "(detached HEAD)"
    upstream = run("git", "rev-parse", "--abbrev-ref", "@{u}", check=False)
    target = (
        upstream.stdout.strip()
        if upstream.returncode == 0
        else "no upstream, push with -u"
    )
    count = run("git", "rev-list", "--count", *UNPUSHED).stdout.strip()
    report("ok", "branch", f"{branch} -> {target}, {count} unpushed commit(s)")


# ssh as git runs it for this repo: core.sshCommand can pick a key per repo, so plain ssh
# may greet another account. Through the shell, as git does, which also expands its `~`.
def git_ssh(*args, check=True):
    command = (
        os.environ.get("GIT_SSH_COMMAND")
        or run("git", "config", "core.sshCommand", check=False).stdout.strip()
        or "ssh"
    )
    return run("sh", "-c", f'{command} "$@"', "ssh", *args, check=check)


def check_identity():
    url = run("git", "remote", "get-url", "--push", "origin").stdout.strip()
    ssh_url = re.match(r"^(?:ssh://)?git@([^:/]+)[:/](.+?)(?:\.git)?/?$", url)
    if not ssh_url:
        if "github.com" in url:
            report(
                "FAIL",
                "identity",
                f"origin {url} is not SSH, so the credential helper picks the account unchecked",
            )
        else:
            report("ok", "identity", f"skipped, origin {url} is not on GitHub")
        return
    host, repo = ssh_url.groups()
    # Resolves ~/.ssh/config aliases such as github-work -> github.com
    hostname = re.search(r"^hostname (\S+)$", git_ssh("-G", host).stdout, re.M).group(1)
    if hostname != "github.com":
        report("ok", "identity", f"skipped, origin {url} is not on GitHub")
        return
    # GitHub greets on stderr and exits 1, since it offers no shell
    greeting = git_ssh(
        "-T",
        "-o",
        "BatchMode=yes",
        "-o",
        "ConnectTimeout=10",
        f"git@{host}",
        check=False,
    ).stderr
    ssh_account = re.search(r"Hi ([^!]+)!", greeting)
    if not ssh_account:
        report(
            "FAIL",
            "identity",
            f"ssh to {host} did not authenticate: {greeting.strip()}",
        )
        return
    gh_user = run("gh", "api", "user", "--jq", ".login", check=False)
    if gh_user.returncode != 0:
        # Without gh the ssh account is the identity, and only a repo under that same
        # account proves it may push there
        owner = repo.split("/")[0]
        if owner != ssh_account.group(1):
            report(
                "FAIL",
                "identity",
                f"gh is logged out and {repo} is not under {ssh_account.group(1)}, "
                "so push access can't be checked (gh auth login)",
            )
            return
        report("ok", "identity", f"{owner} via ssh, owner of {repo} (gh logged out)")
        report("warn", "visibility", "unchecked while gh is logged out")
        return
    gh_account = gh_user.stdout.strip()
    if ssh_account.group(1) != gh_account:
        report(
            "FAIL",
            "identity",
            f"ssh authenticates as {ssh_account.group(1)}, gh as {gh_account}",
        )
        return
    view = json.loads(
        run("gh", "repo", "view", repo, "--json", "visibility,viewerPermission").stdout
    )
    if view["viewerPermission"] not in PUSH_PERMISSIONS:
        report(
            "FAIL",
            "identity",
            f"{gh_account} has {view['viewerPermission']} on {repo}, not push access",
        )
        return
    report(
        "ok",
        "identity",
        f"{gh_account} (ssh and gh agree), {view['viewerPermission']} on {repo}",
    )
    if view["visibility"] == "PUBLIC":
        report(
            "warn", "visibility", f"{repo} is PUBLIC: a pushed secret must be rotated"
        )


def gitleaks(*args):
    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp, "report.json")
        run("gitleaks", *args, "--no-banner", "--redact", "--log-level", "error", "--exit-code", "0",
            "--report-format", "json", "--report-path", str(out))  # fmt: skip
        return json.loads(out.read_text() or "[]")


def untracked_findings(paths):
    # gitleaks dir knows nothing of .gitignore, so it scans a copy of exactly these files
    with tempfile.TemporaryDirectory() as tmp:
        for path in paths:
            Path(tmp, path).parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, Path(tmp, path))
        findings = gitleaks("dir", tmp)
    for finding in findings:
        finding["File"] = os.path.relpath(finding["File"], tmp)
    return findings


def paths(*git_args):
    return {path for path in run("git", *git_args, "-z").stdout.split("\0") if path}


def check_secrets():
    findings = gitleaks("git", "--log-opts", " ".join(UNPUSHED))
    files, scope = set(), "unpushed commits"
    if not HOOK:
        # Filename checks run only here, where the user answers for each hit. A hook can't
        # accept a hit, so it would block every later push of a file such as `.env.ci`.
        untracked = paths("ls-files", "--others", "--exclude-standard")
        files = untracked | paths("diff", "--name-only", "--diff-filter=d", "HEAD")
        files |= paths("log", "--name-only", "--diff-filter=d", "--format=", *UNPUSHED)
        findings += gitleaks("git", "--pre-commit") + gitleaks(
            "git", "--pre-commit", "--staged"
        )
        findings += untracked_findings(sorted(untracked))
        scope = "uncommitted files and unpushed commits"

    flagged = False
    for path in sorted(files):
        name = Path(path).name
        if name.endswith(TEMPLATE_SUFFIXES):
            continue
        if any(fnmatch.fnmatch(name, pattern) for pattern in SECRET_FILES):
            report("FAIL", "secret file", path)
            flagged = True
        elif (
            any(fnmatch.fnmatch(name, pattern) for pattern in VAULT_FILES)
            and Path(path).exists()
        ):
            if not Path(path).read_text().startswith("$ANSIBLE_VAULT;"):
                report("FAIL", "secret file", f"{path} is an unencrypted Ansible vault")
                flagged = True
    for path, line, rule, commit in sorted(
        {
            (f["File"], f["StartLine"], f["RuleID"], f.get("Commit", "")[:7])
            for f in findings
        }
    ):
        report(
            "FAIL",
            "secret",
            f"{path}:{line} {rule}" + (f" in commit {commit}" if commit else ""),
        )
        flagged = True
    if not flagged:
        report(
            "ok",
            "secrets",
            f"gitleaks clean on {scope}"
            + (", no secret-looking filenames" if not HOOK else ""),
        )


def main():
    if HOOK:
        hook_input = json.load(sys.stdin)
        # The hook's `if` filter also fires on any command with $(), backticks or $VAR, so the
        # script decides; `git -C dir push` and `timeout 30 git push` count as pushes
        if not PUSH.search(hook_input["tool_input"]["command"]):
            return
        os.chdir(hook_input["cwd"])
    os.chdir(run("git", "rev-parse", "--show-toplevel").stdout.strip())
    if not HOOK:
        check_branch()
    check_identity()
    check_secrets()


if HOOK:
    try:
        main()
    except Exception as error:
        # A gate that crashes must block: exit 1 would let the push through
        report("FAIL", "preflight", f"crashed, push blocked: {error!r}")
    failures = [line for status, line in results if status == "FAIL"]
    if failures:
        print(
            "github-push preflight blocked this push:",
            *failures,
            sep="\n",
            file=sys.stderr,
        )
        sys.exit(2)
else:
    main()
    print(*(line for _, line in results), sep="\n")
    sys.exit(1 if any(status == "FAIL" for status, _ in results) else 0)
