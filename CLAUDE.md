# dotfiles

Personal dotfiles managed via symlinks. `install.sh` is the entry point — it creates symlinks from this repo to their target locations on the filesystem.

## Target environments

There are two distinct environments these dotfiles need to support. Changes must be tested mentally against both:

**MacBook (primary dev machine)**
- macOS, GUI apps, full toolchain
- Homebrew for package management
- 1Password desktop app manages SSH agent and key storage
- Git commit signing via SSH (key: `id_ed25519_sk`) — only here, not on servers
- Karabiner-Elements for keyboard remapping
- kubectl, flux CLI installed locally for inspecting and verifying remote cluster workloads
- GitHub SSH keys live here only

**Servers (Debian / Raspberry Pi OS Lite)**
- Headless, no GUI
- apt for package management
- zsh + Oh My Zsh installed (same shell setup as MacBook)
- SSH auth via 1Password agent forwarding from the MacBook — no SSH keys stored on servers
- Runs K3s with Flux CD for GitOps workloads
- No committing or signing from servers — the dotfiles repo is the only repo intentionally synced here, via `git pull` only
- No Karabiner, no Homebrew

## Deployment model

Changes are authored and committed on the MacBook, pushed to GitHub, then deployed to servers with `git pull`. Because the repo files are symlinked to their target locations, a `git pull` is all that's needed — the updated files are live immediately with no further steps.

A GitHub ruleset on this repo rejects unsigned commits, so pushing is gated on
signing. Work is committed unsigned (see the YubiKey policy in the global
CLAUDE.md), then re-signed in one session with `resign` — a shell function in
`oh-my-zsh-custom/aliases.zsh`, no arguments, same call on `main` or a branch.
On a feature branch it re-signs the whole branch, including commits already pushed
(force-push after). On `main` it only touches unpushed commits, so published history
is never rewritten.

**Strongly prefer changes that deploy via `git pull` alone.** Avoid changes that require a script to be run on each machine (e.g. running `install.sh` again, running `source ~/.zshrc` manually). Adding a brand-new symlinked file is the one exception — it requires a one-time `install.sh` run on each machine — so prefer extending existing tracked files over adding new ones where the choice is neutral.

## Aliases — long-term goal

`oh-my-zsh-custom/aliases.zsh` is intentionally meant to grow over time into a useful library of shortcuts for common maintenance and debugging tasks. When adding aliases, think about the workflows that come up repeatedly on both the MacBook and servers: cluster inspection, service debugging, log tailing, file ops, etc.

Aliases in this file should:
- Work cross-platform unless clearly named or commented as platform-specific
- Be discoverable — group related aliases and add a one-line comment for non-obvious ones
- Prefer short names for high-frequency commands, longer descriptive names for infrequent but complex ones

## Non-negotiables

These two things must work correctly on every machine, including a fresh Debian server with no extras installed:

1. **Custom shell prompt** — the timestamp + user + host + path prompt in `.zshrc`. The out-of-the-box prompt is not acceptable.
2. **`ls` defaults** — `ls -lah --color=auto`. Must work on both macOS `ls` and GNU `ls`.

When making changes that affect either of these, verify the change works on both platforms before closing the issue.

## What's managed

| Path in repo | Symlinks to | Platform |
|---|---|---|
| `zsh/.zshrc` | `~/.zshrc` | Both |
| `git/.gitconfig` | `~/.gitconfig` | Both |
| `git/.gitignore_global` | `~/.gitignore_global` | Both |
| `oh-my-zsh-custom/aliases.zsh` | `~/.oh-my-zsh/custom/aliases.zsh` | Both |
| `tmux/.tmux.conf` | `~/.tmux.conf` | Both |
| `karabiner/karabiner.json` | `~/.config/karabiner/karabiner.json` | macOS only |
| `claude/settings.json` | `~/.claude/settings.json` | Both |
| `claude/statusline-command.sh` | `~/.claude/statusline-command.sh` | Both |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | Both |

## Machine-local config (untracked)

`~/.gitconfig_local` holds machine-specific git config (signing keys on the MacBook). It is not symlinked by `install.sh` — it must be created manually on each machine. The base `.gitconfig` pulls it in via `[include]`; git silently ignores a missing file, so servers work without it. Setup instructions are in README.

## Platform guards

Use OS detection rather than hardcoding platform assumptions. Prefer file/command existence checks over OS checks where possible (more portable):

```zsh
# Prefer this (works on both platforms naturally):
[ -f /etc/rancher/k3s/k3s.yaml ] && export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Use this when something is genuinely OS-specific:
[[ "$OSTYPE" == darwin* ]] && ...
```

`install.sh` has `IS_MAC` / `IS_LINUX` boolean vars for guarding platform-specific symlinks and setup steps.

## Security rules

- Never commit SSH private keys — only config files and `allowed_signers`
- `~/.ssh/config` symlink target must be `chmod 600` after creation
- Review any new file added to `ssh/` before committing to ensure it contains no embedded secrets

## Open issues

See [GitHub Issues](https://github.com/timgladwell/dotfiles/issues) for the current backlog. Key ones that affect the overall structure:
- Brewfile (#8) — macOS only
- OS detection in install.sh (#7) — prerequisite for several others
