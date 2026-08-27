#!/usr/bin/env zsh

set -e  # Exit on error

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# OS detection
IS_MAC=false
IS_LINUX=false
case "$OSTYPE" in
  darwin*) IS_MAC=true ;;
  linux*)  IS_LINUX=true ;;
esac

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
    "zsh/.zprofile:$HOME/.zprofile"
    "git/.gitconfig:$HOME/.gitconfig"
    "git/.gitignore_global:$HOME/.gitignore_global"
    "oh-my-zsh-custom/aliases.zsh:$HOME/.oh-my-zsh/custom/aliases.zsh"
    "tmux/.tmux.conf:$HOME/.tmux.conf"
    "claude/settings.json:$HOME/.claude/settings.json"
    "claude/statusline-command.sh:$HOME/.claude/statusline-command.sh"
    "claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
)

# macOS-only symlinks. The Grafana MCP launcher reads its token from 1Password,
# which the servers do not have.
if $IS_MAC; then
    filepath_pairs+=("claude/mcp-grafana.sh:$HOME/.claude/mcp-grafana.sh")
fi

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
        echo -n "    Overwrite? (y/n) "
        read -r REPLY
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
    
    # Create the symlink (without -f since we handle existing files above)
    ln -s "$source_path" "$target_path"
    echo -e "${GREEN}  ✓ Created symlink${NC}"
    echo ""
done

echo -e "${GREEN}Dotfiles installation complete!${NC}"

# Offer Homebrew package install (macOS only — Brewfile contains dev tooling, not appropriate for all machines)
if $IS_MAC; then
    echo ""
    echo -n "Set MacOS defaults? (y/n) "
    read -r REPLY
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        "$DOTFILES_DIR/macos/defaults.sh"
        echo -e "${GREEN}MacOS defaults set.${NC}"
    else
        echo "  Skipping. Run '$DOTFILES_DIR/macos/defaults.sh' manually when ready."
    fi

    if command -v brew &>/dev/null; then
        echo ""
        echo -n "Install Homebrew packages from Brewfile? (y/n) "
        read -r REPLY
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew bundle --file="$DOTFILES_DIR/Brewfile"
            echo -e "${GREEN}Homebrew packages installed.${NC}"
        else
            echo "  Skipping. Run 'brew bundle --file=$DOTFILES_DIR/Brewfile' manually when ready."
        fi
    else
        echo -e "${YELLOW}Homebrew not found — skipping Brewfile. Install Homebrew first, then run 'brew bundle --file=$DOTFILES_DIR/Brewfile'.${NC}"
    fi
fi
