#!/usr/bin/env bash

PASS=0
WARN=0
FAIL=0

check_symlink() {
  if [[ -L "$1" ]]; then
    echo "  [OK] $1"
    ((PASS++))
  elif [[ -e "$1" ]]; then
    echo "  [WARN] $1 exists but is not a symlink"
    ((WARN++))
  else
    echo "  [FAIL] $1 missing"
    ((FAIL++))
  fi
}

check_dir() {
  if [[ -d "$1" ]]; then
    echo "  [OK] $1"
    ((PASS++))
  else
    echo "  [WARN] $1 missing"
    ((WARN++))
  fi
}

check_file() {
  if [[ -f "$1" ]]; then
    echo "  [OK] $1"
    ((PASS++))
  else
    echo "  [WARN] $1 missing — $2"
    ((WARN++))
  fi
}

echo "Checking symlinks..."
check_symlink "$HOME/.zshrc"
check_symlink "$HOME/.zshenv"
check_symlink "$HOME/.p10k.zsh"
check_symlink "$HOME/.gitconfig"
check_symlink "$HOME/.tmux.conf"
check_symlink "$HOME/.tmuxline.conf"
check_symlink "$HOME/.config/zsh/zshrc.sh"
check_symlink "$HOME/.config/zsh/custom/functions.zsh"
check_symlink "$HOME/.config/kitty/kitty.conf"
check_symlink "$HOME/.config/cmux/cmux.json"
check_symlink "$HOME/.config/ghostty/config"
check_symlink "$HOME/.config/yabai/yabairc"
check_symlink "$HOME/.config/skhd/skhdrc"
check_symlink "$HOME/.config/spacebar/spacebarrc"
check_symlink "$HOME/.config/nvim/init.lua"
check_symlink "$HOME/.ssh/config"

echo ""
echo "Checking cloned repos..."
check_dir "$HOME/.config/zsh"
check_file "$HOME/.config/zsh/oh-my-zsh.sh" "oh-my-zsh not installed"
if [[ -d "$HOME/.config/zsh/custom/themes/powerlevel10k" || -d "$HOME/.config/zsh/themes/powerlevel10k" ]]; then
  echo "  [OK] powerlevel10k theme"
  ((PASS++))
else
  echo "  [WARN] powerlevel10k theme missing"
  ((WARN++))
fi
check_dir "$HOME/.config/zsh/custom/plugins/zsh-autosuggestions"
check_dir "$HOME/.config/zsh/custom/plugins/zsh-syntax-highlighting"
check_dir "$HOME/.tmux/plugins/tpm"

echo ""

echo ""
echo "Checking commands..."
for cmd in brew stow nvim tmux git gh; do
  if command -v "$cmd" &>/dev/null; then
    echo "  [OK] $cmd"
    ((PASS++))
  else
    echo "  [WARN] $cmd not found"
    ((WARN++))
  fi
done

echo ""
echo "Checking fonts..."
if system_profiler SPFontsDataType 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
  echo "  [OK] JetBrainsMono Nerd Font"
  ((PASS++))
else
  echo "  [WARN] JetBrainsMono Nerd Font not found — kitty/p10k need it"
  ((WARN++))
fi

echo ""
echo "Checking tmux status scripts..."
check_file "$HOME/.local/bin/cpu_percentage.sh" "tmux status bar will show blank"
check_file "$HOME/.local/bin/batt.sh" "tmux status bar will show blank"

echo ""
echo "Checking system scripts..."
for plist in local.dotfiles.cleanup-desktop local.dotfiles.cleanup-downloads local.dotfiles.cleanup-tmp; do
  check_file "$HOME/Library/LaunchAgents/${plist}.plist" "launchd agent not installed"
done

echo ""

echo ""
echo "Checking optional tools..."
for cmd in pyenv cargo node go; do
  if command -v "$cmd" &>/dev/null; then
    echo "  [OK] $cmd"
    ((PASS++))
  else
    echo "  [INFO] $cmd not found (optional)"
  fi
done

echo ""
echo "Results: $PASS passed, $WARN warnings, $FAIL failures"
