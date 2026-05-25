# dotfiles

Personal dotfiles managed via symlinks. Run `install.sh` to set up symlinks on a new machine.

## Setup

### All machines

```sh
git clone git@github.com:timgladwell/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

### MacBook — additional manual step

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
