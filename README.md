# dotfiles

My macOS development environment: zsh with oh-my-zsh and powerlevel10k, Neovim (LazyVim),
tmux, kitty and Ghostty, cmux, and a tiling window manager setup (yabai, skhd, spacebar).
Managed with GNU Stow, for Apple Silicon.

## Install

```bash
git clone https://github.com/ZoneMix/dotfiles-public.git ~/dotfiles
```

```bash
cd ~/dotfiles && ./install.sh
```

It installs Homebrew and the packages in `Brewfile`, clones the shell and tmux plugins,
symlinks the configs into your home folder, and installs three small cleanup agents. Files it
would overwrite are moved to `~/.dotfiles-backup/` first.

Afterward:

1. Set your name and email in `git/.gitconfig`.
2. Put secrets and machine-specific settings in `~/.profile.local` (created from
   `templates/profile.template`).
3. Run `gh auth login`.

Want only one piece? Stow a single package:

```bash
stow --dir ~/dotfiles --target ~ nvim
```

## What's inside

| Folder | What it configures |
|---|---|
| `shell/`, `zsh/` | zsh, prompt, aliases and helper functions (age and GPG encryption, history formatting) |
| `nvim/` | Neovim with LazyVim |
| `tmux/` | tmux with vim-style panes and a status line |
| `kitty/`, `ghostty/`, `cmux/` | terminals |
| `wm/` | yabai, skhd, spacebar |
| `git/` | git defaults, with GitHub auth through `gh` |
| `system/` | launchd agents that tidy Desktop, Downloads and tmp folders |
| `Brewfile` | every package and app |

Review `system/local-bin/` before installing: the cleanup scripts move or delete old files on
a schedule.

For my AI coding setup (agent rules, hooks, skills), see
[ai-onboarding](https://github.com/ZoneMix/ai-onboarding).

## License

MIT. See `LICENSE`.
