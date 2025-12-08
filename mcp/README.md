# MCP Server Configuration

Centralized MCP (Model Context Protocol) server configurations for Claude Code.

## Architecture Principles

1. **Container-managed lifecycle** - Run MCP servers as containers we control, not spawned by Claude Code, to minimize CLI resource usage
2. **Compiled proxies** - Prefer Go/Rust over Node.js/Python for always-on background services
3. **Explicit configuration** - No fallback values; ports and scopes must be explicitly set
4. **Streamable HTTP transport** - Use `--transport http`, not SSE
5. **Namespaced env vars** - Prefix all variables with `<SERVER>_MCP_` (e.g., `GITHUB_MCP_PORT`, `AGENT_MAIL_MCP_PORT`)
6. **Public ECR base images** - Use `public.ecr.aws/docker/library/` (docker sux)

## Transport Protocol

Use **Streamable HTTP** (`/mcp` endpoint). SSE was deprecated in March 2025.

SSE uses a dual-endpoint architecture (GET `/sse` + POST `/messages`) that causes race conditions with Claude Code - POST requests arrive before the session is stored, resulting in empty responses. Streamable HTTP uses a single endpoint with bidirectional streaming, avoiding these synchronization issues.

## Proxy Base Image

The `proxy/` directory contains a reusable base image for [stephenlacy/mcp-proxy](https://github.com/stephenlacy/mcp-proxy) (Rust). Build it once, then use it in server Dockerfiles:

```bash
cd proxy && make build
```

Server Dockerfiles then simply:

```dockerfile
FROM mcp-proxy:latest
COPY --from=<server-image> /path/to/server /usr/local/bin/
CMD mcp-proxy --port $MCP_PORT --host 0.0.0.0 --transport streamable-http --pass-environment -- <server> stdio
```

The proxy version is pinned by commit SHA in `proxy/Dockerfile`. Install from GitHub, not crates.io - the published crate lacks Streamable HTTP support.

### Alternatives Considered

- **[sparfenyuk/mcp-proxy](https://github.com/sparfenyuk/mcp-proxy)** - Python; avoid for always-on services
- **[TBXark/mcp-proxy](https://github.com/TBXark/mcp-proxy)** - Go; requires JSON config file for auth instead of environment variables
- **[mcp-proxy (npm)](https://www.npmjs.com/package/mcp-proxy)** - Node.js; resource intensive

## Claude Code Registration

```bash
claude mcp add --transport http --scope <scope> <name> http://localhost:<port>/mcp
```

Scopes: `local` (default), `user`, `project`

**Note**: Restart Claude Code after rebuilding or restarting MCP server containers. The client caches session state and will return errors (e.g., HTTP 406) until reconnected.

## Healthchecks

Use podman runtime flags instead of Dockerfile `HEALTHCHECK` (OCI format compatibility):

```makefile
podman run -d --name $(CONTAINER) \
    --health-cmd "nc -z localhost 8080" \
    --health-interval 30s \
    --health-timeout 3s \
    --health-start-period 5s \
    --health-retries 3 \
    $(IMAGE)
```

## Directory Structure

```
proxy/              # Reusable mcp-proxy base image
├── Dockerfile
└── Makefile

<server>/           # Server-specific configuration
├── Dockerfile      # Uses FROM mcp-proxy:latest
├── Makefile        # build, start, stop, register, unregister, logs, status, clean
├── .env            # Local configuration (not committed)
└── .env.example    # Configuration template
```

## Port Assignment

Servers are assigned sequential ports starting at 7100:

| Port | Server | Description |
|------|--------|-------------|
| 7100 | github | GitHub API |
| 7101 | agent-mail | Inter-agent messaging |

## Current Servers

- `github/` - [GitHub MCP Server](https://github.com/github/github-mcp-server)
- `agent-mail/` - [Agent Mail](https://github.com/Dicklesworthstone/mcp_agent_mail) - Inter-agent communication

## References

- [MCP Specification - Transports](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports)
- [Why MCP Deprecated SSE](https://blog.fka.dev/blog/2025-06-06-why-mcp-deprecated-sse-and-go-with-streamable-http/)
- [Claude Code MCP Docs](https://docs.anthropic.com/en/docs/claude-code/mcp)
