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
```

This file is intentionally not tracked — signing is MacBook-only and the key path is hardcoded to macOS. The base `.gitconfig` includes it via `[include]`; git silently ignores it on machines where it doesn't exist.

## Fetching updates

A `git pull` is all that's needed — symlinked files update immediately with no further steps required:

```sh
cd ~/.dotfiles && git pull
```

## What's managed

| Path in repo | Symlinks to | Platform |
|---|---|---|
| `zsh/.zshrc` | `~/.zshrc` | Both |
| `git/.gitconfig` | `~/.gitconfig` | Both |
| `git/.gitignore_global` | `~/.gitignore_global` | Both |
| `oh-my-zsh-custom/aliases.zsh` | `~/.oh-my-zsh/custom/aliases.zsh` | Both |
| `karabiner/karabiner.json` | `~/.config/karabiner/karabiner.json` | macOS only |
