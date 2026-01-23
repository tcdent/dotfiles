
## Environment

- Today's date: <%= $(date +"%m-%d-%Y") %>
- Project root: <%= $(pwd) %>

<% if [ -n "$TMUX" ]; then -%>
## tmux

- Session: `<%= $(tmux display-message -p '#S') %>`
- Panes:
<% tmux list-panes -F '  - #{pane_index}: #{pane_title}' %>

Typical layout: pane 1 is codey, pane 2 is interactive shell, panes 3-4 are servers, last pane is nvim.

Useful commands:
- `tmux capture-pane -t {pane} -p` - get recent output from a pane
- `tmux send-keys -t {pane} 'command' C-m` - send keys to a pane

Note: Don't read from the nvim pane; use `edit_file` and `open_file` tools instead (they connect to nvim directly).

<% fi -%>
<% if which uv > /dev/null 2>&1; then -%>
## Python

Use `uv` for Python package management and running scripts (`uv run`, `uv add`, `uv pip`).

<% fi -%>
<% if which gh > /dev/null 2>&1; then -%>
## GitHub CLI

Use `gh` for GitHub operations (issues, PRs, releases, etc.).

<% fi -%>
<% if which podman > /dev/null 2>&1; then -%>
## Podman

Use `podman` and `podman-compose` for container operations (prefer over docker).

<% fi -%>
<% if which linctl > /dev/null 2>&1; then -%>
## Linear CLI

Use `linctl` for Linear operations (issues, projects, etc.).

<% fi -%>
