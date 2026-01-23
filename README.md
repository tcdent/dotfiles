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
brew install neovim tmux neovim-remote ty lazydocker blueutil ruff
rustup component add rust-analyzer
rustup install nightly  # for rustfmt with group_imports
```

Optionally install esh for debugging codey's system template (codey has it built-in, but useful for testing). Use git version - brew is outdated:
```bash
curl -o ~/.local/bin/esh https://raw.githubusercontent.com/jirutka/esh/master/esh && chmod +x ~/.local/bin/esh
```

Set up Claude Code symlinks:
```bash
mkdir -p ~/.claude
ln -sf ~/.config/claude/settings.json ~/.claude/settings.json
ln -sf ~/.config/claude/CLAUDE.md ~/.claude/CLAUDE.md
```

## What's Here

- **nvim/** - Neovim config with lazy.nvim, treesitter, LSP (Python, Rust), copilot, AI diagnostics
- **tmux/** - tmux config with workspaces:
  - `prefix + w` - dev workspace (nvim + 4 shells)
  - `prefix + e` - stats workspace (btop, lazypodman, logs)
  - `prefix + : respawn-pane -k` - restart a pane
- **ghostty/** - Terminal colors and settings, display switching (see [ghostty/README.md](ghostty/README.md))
- **claude/** - Claude Code settings and instructions (symlinked to `~/.claude/`)
- **bin/** - Helper scripts:
  - `nvims` - Open file in current nvim session
  - `nvimw` - Same but waits (for git commits)
  - `dock` / `undock` - Switch Ghostty settings for external/laptop display
  - `ghostty-reload-config` - Reload Ghostty config
  - `lazypodman` - lazydocker wrapper for Podman
  - `release` - Disconnect Bluetooth keyboard/mouse (for switching to another paired Mac)
- **rustfmt/** - Rust formatting config (uses nightly for `group_imports`)

## nvim + tmux Integration

tmux starts nvim with a socket (`/tmp/nvim-<session>.sock`). The `nvims`/`nvimw` scripts connect to that socket, so files opened from terminal panes appear in the running nvim instance.
