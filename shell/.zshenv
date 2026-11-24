[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

[[ -d "$HOME/.foundry/bin" ]] && export PATH="$HOME/.foundry/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"

# Source local secrets (gitignored)
[[ -f "$HOME/.zshenv.local" ]] && . "$HOME/.zshenv.local"

# Node uses the macOS trust store (honors deny trust)
export NODE_USE_SYSTEM_CA=1
