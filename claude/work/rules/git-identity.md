# Git identity (work profile)

- Two GitHub accounts, picked by where the repo lives:
  - under `~/personal/`: `chquaggio`, key `~/.ssh/id_ed25519`, through
    `core.sshCommand` in `~/.gitconfig-personal`;
  - anywhere else: `christianquaggio`, key `~/.ssh/work`, through `Host github.com`
    in `~/.ssh/config`.
- A `chquaggio` repo is cloned under `~/personal/`; elsewhere it pushes as the work
  account.
- Plain `ssh -T git@github.com` always greets `christianquaggio`. The account a repo
  pushes as is the one its own ssh command greets, run from inside the repo:
  `sh -c "$(git config core.sshCommand || echo ssh) -T git@github.com"`.
- Before any push, that greeting must name the account `git remote get-url origin`
  lives under, and `gh auth status`, when logged in, the same account. Otherwise stop
  and ask — never push under a mismatched identity.
