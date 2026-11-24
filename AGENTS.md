# dotfiles

macOS dotfiles managed with GNU Stow. Targets Apple Silicon with Homebrew at `/opt/homebrew`.

## Commands

```bash
./install.sh
./scripts/link.sh
./scripts/verify.sh
shellcheck install.sh scripts/*.sh system/local-bin/*.sh
```

`install.sh` runs the phases in order: bootstrap (Xcode tools, Homebrew, stow), brew
(`Brewfile`), post-install (oh-my-zsh, powerlevel10k, tmux plugins, nvim plugins), stow
(symlinks), system (launchd agents and `~/.local/bin` scripts), verify. Post-install runs
before stow because the shell config expects oh-my-zsh to exist. The phase scripts are sourced
by `install.sh` and inherit its options; run one alone with `DOTFILES` exported.

## Layout

Each top-level folder is a stow package and mirrors the home directory exactly.

| Path | Becomes |
|---|---|
| `shell/` | `~/.zshrc`, `~/.zshenv`, `~/.p10k.zsh` |
| `zsh/` | `~/.config/zsh/zshrc.sh` and `custom/*.zsh` (every `.zsh` file there is sourced) |
| `git/` | `~/.gitconfig` |
| `tmux/`, `kitty/`, `ghostty/`, `cmux/`, `nvim/` | their config under `~` or `~/.config` |
| `wm/` | yabai, skhd and spacebar config |

Not stow packages: `scripts/` (install phases and tmux status helpers), `system/` (cleanup
scripts and their launchd agents, installed by `scripts/install-system.sh`), `templates/`.

## Rules

- **No secrets, ever.** Secrets and machine-specific exports live in `~/.profile.local` and
  `~/.zshenv.local`, which are gitignored and sourced if present. No hostnames, IP addresses
  or SSH config in this repo.
- **No absolute home paths.** Use `$HOME`. The launchd plists use the placeholder `__HOME__`,
  which `install-system.sh` replaces at install time.
- **Adding a stow package:** create the folder mirroring the path from `$HOME`, add it to
  `PACKAGES` in `scripts/link.sh`, and add its checks to `scripts/verify.sh`.
- **Stow needs parent folders.** If `~/.config/<tool>/` doesn't exist, stow links the whole
  folder instead of the file. `link.sh` backs up conflicting files to `~/.dotfiles-backup/`.
- Scripts use `#!/usr/bin/env bash`. Run `gitleaks dir .` before every commit.
