#!/bin/bash

set -e  # Exit on error

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Oh My Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}Oh My Zsh not found. Installing...${NC}"
    
    # Check if curl is available
    if command -v curl &> /dev/null; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # Fall back to wget if curl is not available
    elif command -v wget &> /dev/null; then
        sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo -e "${RED}Error: Neither curl nor wget is available. Please install one of them first.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Oh My Zsh is already installed.${NC}"
fi

# Dotfiles symlink installer
# This script creates symlinks from your dotfiles repo to their target locations

# Dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"

# Array of filepath pairs: "source_in_repo:target_location"
# Source paths are relative to $DOTFILES_DIR
# Target paths should be absolute (use $HOME) or relative to home
filepath_pairs=(
    "zsh/.zshrc:$HOME/.zshrc"
    "git/.gitconfig:$HOME/.gitconfig"
    "oh-my-zsh-custom/aliases.zsh:$HOME/.oh-my-zsh/custom/aliases.zsh"
)

echo "Starting dotfiles symlink installation..."
echo "Dotfiles directory: $DOTFILES_DIR"
echo ""

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${RED}Error: Dotfiles directory not found at $DOTFILES_DIR${NC}"
    exit 1
fi

# Process each filepath pair
for pair in "${filepath_pairs[@]}"; do
    # Split the pair into source and target
    IFS=':' read -r source target <<< "$pair"
    
    # Get full source path
    source_path="$DOTFILES_DIR/$source"
    
    # Expand target path (handles $HOME and ~)
    target_path=$(eval echo "$target")
    
    echo "Processing: $source -> $target_path"
    
    # Check if source exists
    if [ ! -e "$source_path" ]; then
        echo -e "${YELLOW}  ⚠ Warning: Source does not exist: $source_path${NC}"
        echo -e "${YELLOW}    Skipping...${NC}"
        echo ""
        continue
    fi
    
    # Create target directory if it doesn't exist
    target_dir=$(dirname "$target_path")
    if [ ! -d "$target_dir" ]; then
        echo "  Creating directory: $target_dir"
        mkdir -p "$target_dir"
    fi
    
    # Check if target already exists
    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        # Check if it's already the correct symlink
        if [ -L "$target_path" ]; then
            existing_link=$(readlink "$target_path")
            if [ "$existing_link" = "$source_path" ]; then
                echo -e "${GREEN}  ✓ Symlink already exists and is correct${NC}"
                echo ""
                continue
            fi
        fi
        
        echo -e "${YELLOW}  ⚠ Target already exists: $target_path${NC}"
        read -p "    Overwrite? (y/n) " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$target_path"
            echo "  Removed existing file/directory"
        else
            echo "  Skipping..."
            echo ""
            continue
        fi
    fi
    
    # Create the symlink
    ln -sf "$source_path" "$target_path"
    echo -e "${GREEN}  ✓ Created symlink${NC}"
    echo ""
done

echo -e "${GREEN}Dotfiles installation complete!${NC}"