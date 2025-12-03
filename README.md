# dotfiles

Personal config for tmux, nvim, and ghostty.

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

## What's Here

- **nvim/** - Neovim config with lazy.nvim, treesitter, LSP, copilot
- **tmux/** - tmux config with dev workspace layout (`prefix + w`)
- **ghostty/** - Terminal colors and settings
- **bin/** - Helper scripts:
  - `nvims` - Open file in current nvim session
  - `nvimw` - Same but waits (for git commits)

## nvim + tmux Integration

tmux starts nvim with a socket (`/tmp/nvim-<session>.sock`). The `nvims`/`nvimw` scripts connect to that socket, so files opened from terminal panes appear in the running nvim instance.
