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
brew install neovim tmux neovim-remote ty lazydocker blueutil ruff watchman
rustup component add rust-analyzer
rustup install nightly  # for rustfmt with group_imports
```

`watchman` must come from brew. Debian ships 4.9.0 (2017) in every suite
including sid and the package is orphaned; the upstream prebuilt Linux zip
needs glibc 2.38 and bookworm has 2.36. Neovim's `filewatch` module treats a
missing or dead daemon as a misconfigured system and reports it as an error
rather than falling back — see [nvim/lua/filewatch.lua](nvim/lua/filewatch.lua).

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

- **nvim/** - Neovim config with lazy.nvim, treesitter, LSP (Python, Rust), AI diagnostics
  - `lua/filewatch.lua` - watchman-backed file change events; the single source
    of truth for buffer reloads, the file tree and the diff view
  - `lua/agent.lua` - integration points for an agent driving the editor over
    the nvim socket: open a file at a range, lay files out in columns, annotate
    lines, drive the diff view, read back what is on screen. Called via
    `bin/agent-nvim`; documented for other agents by the `nvim-editor-control`
    skill in `agent/skills/`
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
  - `agent-nvim` - Call an `agent.lua` integration point in this session's nvim
    (`agent-nvim --help` lists them); lets an agent show code in the editor
    rather than pasting it into the terminal
  - `dock` / `undock` - Switch Ghostty settings for external/laptop display
  - `ghostty-reload-config` - Reload Ghostty config
  - `lazypodman` - lazydocker wrapper for Podman
  - `release` - Disconnect Bluetooth keyboard/mouse (for switching to another paired Mac)
- **rustfmt/** - Rust formatting config (uses nightly for `group_imports`)

## nvim + tmux Integration

tmux starts nvim with a socket (`/tmp/nvim-<session>.sock`). The `nvims`/`nvimw` scripts connect to that socket, so files opened from terminal panes appear in the running nvim instance.
