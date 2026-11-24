# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source $HOME/.config/zsh/zshrc.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# iTerm2 only — sourcing this under Ghostty/cmux leaks raw OSC 1337 into the prompt.
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi

HISTSIZE=100000
SAVEHIST=250000
setopt append_history
setopt inc_append_history_time
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init -)"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export CLAUDE_PLUGIN_ROOT="$HOME/.claude"

export PATH="$HOME/.claude/bin:$PATH"

# opencode
export PATH=$HOME/.opencode/bin:$PATH

# Added by cua-driver-rs installer — see https://github.com/trycua/cua
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<

# Shred and delete files
alias shred='gshred -u -z -n 3 -v'
