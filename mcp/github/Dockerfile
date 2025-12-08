# GitHub MCP Server
# https://github.com/github/github-mcp-server

FROM ghcr.io/github/github-mcp-server:latest AS github-mcp

FROM mcp-proxy:latest
COPY --from=github-mcp /server/github-mcp-server /usr/local/bin/

# Configuration via environment (see .env)
# GITHUB_PERSONAL_ACCESS_TOKEN - required, from gh auth token
# GITHUB_TOOLSETS - optional, comma-separated toolsets
# GITHUB_TOOLS - optional, comma-separated individual tools
# GITHUB_HOST - optional, GitHub Enterprise hostname

CMD mcp-proxy --port $MCP_PORT --host 0.0.0.0 --transport streamable-http --pass-environment -- github-mcp-server stdio
