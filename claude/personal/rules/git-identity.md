# Git identity (personal profile)

- GitHub account: `chquaggio`. Key: `~/.ssh/id_ed25519`.
- Before any push, `ssh -T git@github.com` must greet `chquaggio` and `gh auth status`
  must show the same account; `git remote get-url origin` must be under `chquaggio/`.
  Otherwise stop and ask — never push under a mismatched identity.
