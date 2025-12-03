#!/bin/bash

# Dotfiles directory
DOTFILES="$HOME/.dotfiles"

# List of files to symlink
files=".zshrc .gitconfig .oh-my-zsh/custom"

# Create symlinks
for file in $files; do
    if [ -f "$HOME/$file" -o -d "$HOME/$file" ]; then
        echo "Backing up existing $file"
        mv "$HOME/$file" "$HOME/${file}.backup"
    fi
    echo "Creating symlink for $file"
    ln -sf "$DOTFILES/$file" "$HOME/$file"
done

echo "Dotfiles installed!"