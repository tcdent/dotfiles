
## Environment

- Today's date: <%= $(date +"%m-%d-%Y") %>
- Project root: <%= $(pwd) %>

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
