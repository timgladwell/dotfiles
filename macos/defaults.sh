#!/usr/bin/env zsh
# Apply macOS system defaults.
# Run manually after a clean install: ./macos/defaults.sh
# Some settings require a logout or restart to take effect.
# Safe to re-run — all writes are idempotent.

set -e

echo "Applying macOS system defaults..."

# ---------------------------------------------------------------------------
# Mouse
# ---------------------------------------------------------------------------

# Traditional (non-natural) scroll direction
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# ---------------------------------------------------------------------------
# Dock
# ---------------------------------------------------------------------------

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock orientation -string "right"
defaults write com.apple.dock tilesize -int 34
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 128
defaults write com.apple.dock show-recents -bool true

# ---------------------------------------------------------------------------
# Hot corners — all disabled
# ---------------------------------------------------------------------------

defaults write com.apple.dock wvous-tl-corner -int 1
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 1
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 1
defaults write com.apple.dock wvous-br-modifier -int 0

# ---------------------------------------------------------------------------
# Finder
# ---------------------------------------------------------------------------

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar and status bar
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Default to list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Keep folders on top when sorting by name (not on desktop)
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool false

# Show drives and servers on desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# ---------------------------------------------------------------------------
# Apply
# ---------------------------------------------------------------------------

for app in "Finder" "Dock"; do
    killall "$app" &>/dev/null || true
done

echo "Done. Log out and back in for scroll direction to take effect."
