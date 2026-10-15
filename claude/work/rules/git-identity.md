# Git identity (work profile)

- The account `gh auth status` reports is the identity; key `~/.ssh/id_ed25519`,
  held by the macOS Keychain (`UseKeychain`/`AddKeysToAgent` in `~/.ssh/config`).
  While gh is logged out, the account `ssh -T git@github.com` greets is the identity,
  and only a repo under that account can be pushed.
- Before any push, `ssh -T git@github.com` must greet that same account and
  `git remote get-url origin` must live under it. Otherwise stop and ask — never
  push under a mismatched identity.
