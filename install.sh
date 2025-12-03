#!/bin/bash

# Check if Oh My Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh not found. Installing..."
    
    # Check if curl is available
    if command -v curl &> /dev/null; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # Fall back to wget if curl is not available
    elif command -v wget &> /dev/null; then
        sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "Error: Neither curl nor wget is available. Please install one of them first."
        exit 1
    fi
else
    echo "Oh My Zsh is already installed."
fi

# Dotfiles directory
DOTFILES="$HOME/.dotfiles"

# List of files to symlink
files=".zshrc .gitconfig .oh-my-zsh/custom"

# Create symlinks
for file in $files; do
    target="$HOME/$file"
    source="$DOTFILES/$file"
    
    # Check if target exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        # If it's already the correct symlink, skip
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
            echo "✓ $file already correctly linked"
            continue
        fi
        
        # If it's a different file or wrong symlink, back it up
        echo "Backing up existing $file"
        mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create the symlink
    echo "Creating symlink for $file"
    ln -sf "$source" "$target"
done

echo "Dotfiles installed!"