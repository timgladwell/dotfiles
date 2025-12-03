#!/bin/bash

# Dotfiles directory
DOTFILES="$HOME/.dotfiles"

# List of files to symlink
files=".zshrc .gitconfig"

# Create symlinks
for file in $files; do
    if [ -f "$HOME/$file" ]; then
        echo "Backing up existing $file"
        mv "$HOME/$file" "$HOME/${file}.backup"
    fi
    echo "Creating symlink for $file"
    ln -sf "$DOTFILES/$file" "$HOME/$file"
done

# Oh My Zsh customization
ln -sf "$DOTFILES/oh-my-zsh/custom/* ~/.oh-my-zsh/custom/

echo "Dotfiles installed!"