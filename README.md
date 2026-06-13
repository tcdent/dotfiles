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

Set up agent symlinks. Claude Code and Codex read the **same** system prompt
from `agent/SYSTEM.md` (one source of truth); Claude's settings are symlinked
into `~/.claude/` as well:
```bash
mkdir -p ~/.claude ~/.codex
# shared system prompt → both tools
ln -sf ~/.config/agent/SYSTEM.md ~/.claude/CLAUDE.md
ln -sf ~/.config/agent/SYSTEM.md ~/.codex/AGENTS.md
# Claude Code settings
ln -sf ~/.config/claude/settings.json ~/.claude/settings.json
```

## What's Here

- **nvim/** - Neovim config with lazy.nvim, treesitter, LSP (Python, Rust), copilot, AI diagnostics
- **tmux/** - tmux config with workspaces:
  - `prefix + w` - dev workspace (nvim + 4 shells)
  - `prefix + e` - stats workspace (btop, lazypodman, logs)
  - `prefix + : respawn-pane -k` - restart a pane
- **ghostty/** - Terminal colors and settings, display switching (see [ghostty/README.md](ghostty/README.md))
- **agent/** - Shared agent system prompt (`SYSTEM.md`) + skills; symlinked into both `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`
- **claude/** - Claude Code `settings.json` (symlinked to `~/.claude/settings.json`)
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
