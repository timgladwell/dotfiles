# dotfiles

Personal dotfiles managed via symlinks. Run `install.sh` to set up symlinks on a new machine.

## Prerequisites

### macOS

[Homebrew](https://brew.sh) is required. Install it first, then use it to install git:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git
```

### Servers (Debian / Raspberry Pi OS)

```sh
sudo apt install -y git zsh
```

## Setup

### macOS

```sh
git clone git@github.com:timgladwell/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

### Servers

Servers have no SSH keys stored locally. Clone over HTTPS instead:

```sh
git clone https://github.com/timgladwell/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

`install.sh` installs Oh My Zsh if not already present, then creates symlinks for all tracked config files.

## Manual steps

### MacBook — system defaults

`install.sh` offers to apply preferred macOS system settings (Dock, Finder, hot corners, mouse scrolling) interactively after the symlinks are set up. To apply or re-apply them later:

```sh
~/.dotfiles/macos/defaults.sh
```

The script is idempotent and safe to re-run. Log out and back in for scroll direction to take effect.

### MacBook — Claude Code plugins

Plugin configuration lives in `.claude-plugin/marketplace.json`. After cloning (or on any machine where Claude Code is installed), register the dotfiles repo as a marketplace source, then install each plugin individually — there is no bulk install:

```sh
/plugin marketplace add timgladwell/dotfiles
/plugin install ponytail@personal
/plugin install prompter@personal
# /plugin install <name>@personal  (repeat for each plugin in marketplace.json)
```

Plugins are installed at user scope and apply to every Claude Code session on the machine. When Renovate opens a PR bumping a plugin version, merge it and re-run the corresponding `/plugin install` command to pick up the new version.

### MacBook — Grafana MCP server

The Grafana MCP server is defined in `claude/mcp-grafana.sh`, which is symlinked to `~/.claude/mcp-grafana.sh` on macOS only. The script reads the service account token from 1Password at launch, so no token is stored in this repo or in `~/.claude.json`.

Create a 1Password item holding the token, then register the server once per machine:

```sh
op item create --category=password --title='Grafana MCP' --vault=homelab \
    'credential=<grafana service account token>'

claude mcp add --scope user grafana ~/.claude/mcp-grafana.sh
```

The script defaults to `op://homelab/Grafana MCP/credential`. Override with `GRAFANA_TOKEN_REF` (or `GRAFANA_URL`) in the environment if your vault or item name differs.

A cold `op` session raises a touch-to-approve prompt on the 1Password desktop app, and the read blocks until it is answered. The script bounds that wait at 25 seconds — inside Claude Code's 30-second MCP startup budget — so an unanswered prompt fails with a message saying so rather than a bare connection timeout. Approve the prompt and reconnect with `/mcp`. Once approved, `op` caches a session and later reads return in under a second. Override the bound with `GRAFANA_TOKEN_WAIT` if 25 seconds is not enough.

`~/.claude.json` is Claude Code's mutable state file — session history, per-project data — so it cannot be symlinked into this repo. Registering the server once writes a pointer to the script into it; everything worth tracking lives in the script.

### MacBook — git commit signing

Git commit signing is not handled by `install.sh`. After running the installer, create `~/.gitconfig_local`:

```ini
[user]
    signingkey = /Users/tim/.ssh/id_ed25519_sk.pub
[gpg]
    format = ssh
[gpg "ssh"]
    allowedSignersFile = /Users/tim/.ssh/allowed_signers
[commit]
    gpgsign = true
[tag]
    gpgsign = true
[credential "https://github.com"]
    helper =
    helper = !gh auth git-credential
[credential "https://gist.github.com"]
    helper =
    helper = !gh auth git-credential
```

The credential blocks route GitHub/Gist auth through the `gh` CLI instead of the base config's `cache` helper — they rely on `gh` being on `$PATH`, which is only guaranteed on the MacBook.

This file is intentionally not tracked — signing and the `gh`-based credential helper are MacBook-only. The base `.gitconfig` includes it via `[include]`; git silently ignores it on machines where it doesn't exist.

## Fetching updates

A `git pull` is all that's needed — symlinked files update immediately with no further steps required:

```sh
cd ~/.dotfiles && git pull
```

## Ongoing maintenance

### Updating the Brewfile

`brew bundle dump --force` overwrites the Brewfile with a flat, alphabetical list and drops the category comments and grouping — don't run it directly against `Brewfile`.

To find packages you've installed that aren't tracked yet:

```sh
brew bundle cleanup --file=~/.dotfiles/Brewfile
```

This is a dry run — it lists formulae/casks that would be removed if the Brewfile were applied with `--cleanup`. For each one, either add it to the appropriate section of `Brewfile` (if you want to keep it) or `brew uninstall` it (if it was a one-off). Re-run `brew bundle cleanup --file=~/.dotfiles/Brewfile --force` to actually remove anything you didn't add.

To check that everything in the Brewfile is still installed:

```sh
brew bundle check --file=~/.dotfiles/Brewfile --verbose
```

## What's managed

| Path in repo | Symlinks to | Platform |
|---|---|---|
| `zsh/.zshrc` | `~/.zshrc` | Both |
| `git/.gitconfig` | `~/.gitconfig` | Both |
| `git/.gitignore_global` | `~/.gitignore_global` | Both |
| `oh-my-zsh-custom/aliases.zsh` | `~/.oh-my-zsh/custom/aliases.zsh` | Both |
| `tmux/.tmux.conf` | `~/.tmux.conf` | Both |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | Both |
| `claude/mcp-grafana.sh` | `~/.claude/mcp-grafana.sh` | macOS only |
| `karabiner/karabiner.json` | `~/.config/karabiner/karabiner.json` | macOS only |

## macOS-only files (not symlinked)

| Path in repo | Purpose |
|---|---|
| `Brewfile` | Homebrew packages — install interactively via `install.sh` or run `brew bundle --file=~/.dotfiles/Brewfile` |
| `macos/defaults.sh` | System defaults — run manually after a clean install |
