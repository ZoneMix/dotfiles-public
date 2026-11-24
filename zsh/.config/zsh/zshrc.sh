# zshrc

# ZSH Plugins
plugins=(
  aws
  zsh-autosuggestions
  zsh-syntax-highlighting
  git
  brew
  aliases
  thefuck
)

# Environment Variables
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.local/bin:$HOME/go/bin:$PATH"
export ZSH="$HOME/.config/zsh"

export EDITOR=nvim
export ZSH_THEME="powerlevel10k/powerlevel10k"
export ONYX_PATH="$HOME/.onyx"
# Set KEYID (your GPG key id) in ~/.profile.local for encrypt_file.
export LS_COLORS="di=1;35:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
export TZ=UTC

# ZSH Source Files
source $ZSH/oh-my-zsh.sh
[[ -f "$HOME/.profile.local" ]] && source "$HOME/.profile.local"
for _f in "$HOME/.config/zsh/custom"/*.zsh; do
  [[ -f "$_f" ]] && source "$_f"
done
unset _f

# Aliases
alias vim="nvim"
alias c="clear"
alias vi="nvim"
alias ga="git add ."
alias gc="git commit"
alias gp="git push -u origin main"
alias vimrc="vim $HOME/.config/nvim/init.lua"
alias zshrc="vim $HOME/.config/zsh/zshrc.sh"
alias now="date +'%l:%M%p'"
alias yabairc="vi $HOME/.config/yabai/yabairc"
alias skhdrc="vi $HOME/.config/skhd/skhdrc"
alias spacebarrc="vi $HOME/.config/spacebar/spacebarrc"
alias cloud="cd \"$HOME/Library/Mobile Documents/com~apple~CloudDocs\""
alias sl="ls"

# tmux no longer autostarts — cmux is the local multiplexer. tmux is kept for
# remote hosts: `cmux mosh-tmux` attaches to named sessions there.
# These replace the oh-my-zsh tmux plugin's aliases, which also wrapped `tmux`
# itself and forced TERM=screen-256color over the tmux-256color in .tmux.conf.
alias ta="tmux attach -t"
alias tad="tmux attach -d -t"
alias ts="tmux new-session -s"
alias tl="tmux list-sessions"
alias tksv="tmux kill-server"
alias tkss="tmux kill-session -t"

colors() {
  for i in {0..255}; do print -Pn "%K{$i} %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
}
