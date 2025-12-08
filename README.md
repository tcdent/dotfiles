# dotfiles

Personal config files.

## Setup

```bash
git clone <repo> ~/.config
```

Add to `~/.zshrc`:
```bash
export PATH="$HOME/.config/bin:$PATH"
export EDITOR='nvimw'
export GIT_EDITOR='nvimw'
```

Install dependencies:
```bash
brew install neovim tmux neovim-remote pyright
```

Set up Claude Code symlinks:
```bash
mkdir -p ~/.claude
ln -sf ~/.config/claude/settings.json ~/.claude/settings.json
ln -sf ~/.config/claude/CLAUDE.md ~/.claude/CLAUDE.md
```

## What's Here

- **nvim/** - Neovim config with lazy.nvim, treesitter, LSP, copilot
- **tmux/** - tmux config with dev workspace layout (`prefix + w`)
- **ghostty/** - Terminal colors and settings
- **claude/** - Claude Code settings and instructions (symlinked to `~/.claude/`)
- **bin/** - Helper scripts:
  - `nvims` - Open file in current nvim session
  - `nvimw` - Same but waits (for git commits)

## nvim + tmux Integration

tmux starts nvim with a socket (`/tmp/nvim-<session>.sock`). The `nvims`/`nvimw` scripts connect to that socket, so files opened from terminal panes appear in the running nvim instance.
