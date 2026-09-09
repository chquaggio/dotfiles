# Git identity (work profile)

- The account `gh auth status` reports is the identity; key `~/.ssh/id_ed25519`
  (loaded by keychain from `.zshrc`).
- Before any push, `ssh -T git@github.com` must greet that same account and
  `git remote get-url origin` must live under it. Otherwise stop and ask — never
  push under a mismatched identity.
