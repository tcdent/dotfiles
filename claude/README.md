# Claude Code Configuration

Static Claude Code configuration files, symlinked to `~/.claude/`.

## Files

| File | Purpose |
|------|---------|
| `settings.json` | Permissions, env vars, hooks, statusLine |
| `CLAUDE.md` | System instructions loaded into every session |

## Symlink Setup

```bash
ln -s ~/.config/claude/settings.json ~/.claude/settings.json
ln -s ~/.config/claude/CLAUDE.md ~/.claude/CLAUDE.md
```

## What's NOT Tracked

These files remain in `~/.claude/` and are managed dynamically by Claude:

- `settings.local.json` - Local permission overrides (auto-gitignored by Claude)
- `~/.claude.json` - OAuth, MCP servers, per-project state, caches

## Configuration Hierarchy

Settings are merged with this precedence (highest to lowest):

1. **Enterprise policies** - `managed-settings.json` (IT-managed, cannot override)
2. **Command line args** - Temporary session overrides
3. **Local project** - `.claude/settings.local.json`
4. **Shared project** - `.claude/settings.json`
5. **User settings** - `~/.claude/settings.json` (this file via symlink)

## MCP Servers

MCP servers are defined separately from settings.json:

- **User-level**: `~/.claude.json` (not `~/.claude/settings.json`)
- **Project-level**: `.mcp.json` in project root

The `claude mcp add` command manages these automatically.

## Permissions

Three permission levels, processed in order: `Deny → Allow → Ask → Permission Mode`

| Array | Behavior |
|-------|----------|
| `allow` | Auto-approve without prompting |
| `ask` | Explicitly prompt for confirmation |
| `deny` | Block entirely |

Syntax:
- `ToolName` - permit all actions
- `ToolName(*)` - permit any argument
- `ToolName(pattern)` - permit matching calls only (glob patterns supported)

Examples: `Bash(git *)`, `Read(**/.env)`, `Write(*.json)`, `WebFetch(domain:example.com)`

## settings.json Reference

```json
{
  "permissions": {
    "allow": ["Bash(git *)"],
    "ask": ["Bash(make *)"],
    "deny": ["Bash(rm -rf *)"]
  },
  "env": {
    "SOME_VAR": "value"
  },
  "hooks": {
    "PreToolUse": [...],
    "PostToolUse": [...]
  },
  "statusLine": {
    "type": "command",
    "command": "printf '%s' \"$(pwd)\""
  }
}
```

## CLAUDE.md

Instructions in CLAUDE.md are injected into every Claude Code session. Use for:

- Coding style preferences
- Project-agnostic reminders
- Tool usage guidelines

Project-specific instructions go in `.claude/CLAUDE.md` within each project.
