#!/usr/bin/env bash

clone_if_missing() {
  local url="$1" dest="$2" marker="$3"
  if [[ -f "$marker" ]] || [[ -d "$dest/.git" ]]; then
    return 0
  fi
  if [[ -d "$dest" ]]; then
    local tmp
    tmp="$(mktemp -d)"
    git clone --depth=1 "$url" "$tmp"
    cp -a "$tmp/." "$dest/"
    rm -rf "$tmp"
  else
    git clone --depth=1 "$url" "$dest"
  fi
}

OMZ_DIR="$HOME/.config/zsh"
if [[ ! -f "$OMZ_DIR/oh-my-zsh.sh" ]]; then
  echo "  Installing oh-my-zsh..."
  clone_if_missing "https://github.com/ohmyzsh/ohmyzsh.git" "$OMZ_DIR" "$OMZ_DIR/oh-my-zsh.sh"
else
  echo "  oh-my-zsh already installed."
fi

P10K_DIR="$OMZ_DIR/custom/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR/.git" ]]; then
  echo "  Installing powerlevel10k..."
  mkdir -p "$OMZ_DIR/custom/themes"
  clone_if_missing "https://github.com/romkatv/powerlevel10k.git" "$P10K_DIR" "$P10K_DIR/.git"
else
  echo "  powerlevel10k already installed."
fi

ZSH_AUTOSUGGEST="$OMZ_DIR/custom/plugins/zsh-autosuggestions"
if [[ ! -d "$ZSH_AUTOSUGGEST/.git" ]]; then
  echo "  Installing zsh-autosuggestions..."
  mkdir -p "$OMZ_DIR/custom/plugins"
  clone_if_missing "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_AUTOSUGGEST" "$ZSH_AUTOSUGGEST/.git"
else
  echo "  zsh-autosuggestions already installed."
fi

ZSH_SYNTAX="$OMZ_DIR/custom/plugins/zsh-syntax-highlighting"
if [[ ! -d "$ZSH_SYNTAX/.git" ]]; then
  echo "  Installing zsh-syntax-highlighting..."
  mkdir -p "$OMZ_DIR/custom/plugins"
  clone_if_missing "https://github.com/zsh-users/zsh-syntax-highlighting" "$ZSH_SYNTAX" "$ZSH_SYNTAX/.git"
else
  echo "  zsh-syntax-highlighting already installed."
fi

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR/.git" ]]; then
  echo "  Installing TPM (tmux plugin manager)..."
  mkdir -p "$HOME/.tmux/plugins"
  clone_if_missing "https://github.com/tmux-plugins/tpm" "$TPM_DIR" "$TPM_DIR/.git"
else
  echo "  TPM already installed."
fi

if [[ -x "$TPM_DIR/bin/install_plugins" && ! -d "$HOME/.tmux/plugins/tmux-sensible" ]]; then
  echo "  Installing tmux plugins via TPM..."
  "$TPM_DIR/bin/install_plugins" 2>/dev/null || true
else
  echo "  tmux plugins already installed."
fi

mkdir -p "$HOME/.local/bin"
for script in cpu_percentage.sh batt.sh; do
  src="$DOTFILES/scripts/$script"
  dest="$HOME/.local/bin/$script"
  if [[ -f "$src" ]] && ! cmp -s "$src" "$dest" 2>/dev/null; then
    cp "$src" "$dest"
    chmod +x "$dest"
  fi
done

if command -v nvim &>/dev/null && [[ ! -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]]; then
  echo "  Syncing nvim plugins via lazy.nvim (first install)..."
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
  echo "  nvim plugins synced."
else
  echo "  nvim plugins already installed."
fi



if [[ ! -f "$HOME/.profile.local" && -f "$DOTFILES/templates/profile.template" ]]; then
  cp "$DOTFILES/templates/profile.template" "$HOME/.profile.local"
  echo "  Created ~/.profile.local from template — add your own secrets there."
fi



for svc in yabai skhd; do
  if command -v "$svc" &>/dev/null; then
    if ! brew services info "$svc" 2>/dev/null | grep -q "Running: true"; then
      echo "  Starting $svc service..."
      "$svc" --start-service 2>/dev/null || true
    else
      echo "  $svc service already running."
    fi
  fi
done

go_install_if_missing() {
  local pkg="$1"
  local bin="${pkg##*/}"
  if [[ ! -x "$HOME/go/bin/$bin" ]]; then
    echo "    Installing $bin..."
    go install "$pkg" 2>/dev/null || true
  else
    echo "    $bin already installed."
  fi
}

if command -v go &>/dev/null; then
  echo "  Checking Go tools..."
  go_install_if_missing "golang.org/x/tools/gopls@latest"
  go_install_if_missing "honnef.co/go/tools/cmd/staticcheck@latest"
fi

if command -v cargo &>/dev/null; then
  echo "  Checking Cargo tools..."
  for bin in cargo-audit cargo-expand; do
    if [[ ! -x "$HOME/.cargo/bin/$bin" ]]; then
      echo "    Installing $bin..."
      cargo install "$bin" 2>/dev/null || true
    else
      echo "    $bin already installed."
    fi
  done
fi

