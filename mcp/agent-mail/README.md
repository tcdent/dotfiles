# Agent Mail MCP Server

Inter-agent communication system from [Dicklesworthstone/mcp_agent_mail](https://github.com/Dicklesworthstone/mcp_agent_mail). Enables multiple AI agents to send messages to each other through a shared mailbox.

## Setup

1. Copy `.env.example` to `.env` and configure
2. Build and start: `make start`
3. Register with Claude Code: `make register`

## Data Storage

Data is stored at `AGENT_MAIL_DATA_DIR` (default: `~/.local/share/agent-mail/`):

```
$AGENT_MAIL_DATA_DIR/
├── mailbox/          # Git-backed message archive
└── agent_mail.db     # SQLite metadata database
```

This directory persists across container rebuilds.

## Configuration

### Required (our wrapper)

```bash
AGENT_MAIL_MCP_PORT=7101
AGENT_MAIL_MCP_SCOPE=user
AGENT_MAIL_DATA_DIR=$(HOME)/.local/share/agent-mail
```

### Hardcoded (in Dockerfile)

Storage paths are fixed since the host volume always mounts to `/data`:

- `STORAGE_ROOT=/data/mailbox`
- `DATABASE_URL=sqlite+aiosqlite:////data/agent_mail.db`

Note: SQLite URLs use 3 slashes for relative paths (`///./file.db`) and 4 slashes for absolute paths (`////absolute/path/file.db`). The extra slash is required because the path itself starts with `/`.

### Upstream Configuration Reference

All environment variables supported by agent-mail, grouped by category:

**HTTP Server**:
| Variable | Default | Description |
|----------|---------|-------------|
| `HTTP_HOST` | `127.0.0.1` | Bind address |
| `HTTP_PORT` | `8765` | Bind port |
| `HTTP_PATH` | `/mcp/` | MCP endpoint path |
| `HTTP_BEARER_TOKEN` | `` | Auth token (empty = no auth) |
| `HTTP_ALLOW_LOCALHOST_UNAUTHENTICATED` | `true` | Skip auth for localhost |
| `HTTP_REQUEST_LOG_ENABLED` | `false` | Log HTTP requests |

**Rate Limiting**:
| Variable | Default | Description |
|----------|---------|-------------|
| `HTTP_RATE_LIMIT_ENABLED` | `false` | Enable rate limiting |
| `HTTP_RATE_LIMIT_PER_MINUTE` | `60` | Requests per minute |
| `HTTP_RATE_LIMIT_BACKEND` | `memory` | `memory` or `redis` |
| `HTTP_RATE_LIMIT_TOOLS_PER_MINUTE` | `60` | Tool calls per minute |
| `HTTP_RATE_LIMIT_RESOURCES_PER_MINUTE` | `120` | Resource calls per minute |
| `HTTP_RATE_LIMIT_REDIS_URL` | `` | Redis URL for rate limiting |
| `HTTP_RATE_LIMIT_TOOLS_BURST` | `0` | Tool burst allowance |
| `HTTP_RATE_LIMIT_RESOURCES_BURST` | `0` | Resource burst allowance |

**JWT Authentication**:
| Variable | Default | Description |
|----------|---------|-------------|
| `HTTP_JWT_ENABLED` | `false` | Enable JWT auth |
| `HTTP_JWT_ALGORITHMS` | `HS256` | Allowed algorithms (CSV) |
| `HTTP_JWT_SECRET` | `` | JWT secret key |
| `HTTP_JWT_JWKS_URL` | `` | JWKS endpoint URL |
| `HTTP_JWT_AUDIENCE` | `` | Expected audience |
| `HTTP_JWT_ISSUER` | `` | Expected issuer |
| `HTTP_JWT_ROLE_CLAIM` | `role` | Claim containing role |

**RBAC**:
| Variable | Default | Description |
|----------|---------|-------------|
| `HTTP_RBAC_ENABLED` | `true` | Enable role-based access |
| `HTTP_RBAC_READER_ROLES` | `reader,read,ro` | Read-only roles (CSV) |
| `HTTP_RBAC_WRITER_ROLES` | `writer,write,tools,rw` | Read-write roles (CSV) |
| `HTTP_RBAC_DEFAULT_ROLE` | `reader` | Default role |
| `HTTP_RBAC_READONLY_TOOLS` | `health_check,fetch_inbox,...` | Tools allowed for readers |

**CORS**:
| Variable | Default | Description |
|----------|---------|-------------|
| `HTTP_CORS_ENABLED` | `false` | Enable CORS |
| `HTTP_CORS_ORIGINS` | `` | Allowed origins (CSV) |
| `HTTP_CORS_ALLOW_CREDENTIALS` | `false` | Allow credentials |
| `HTTP_CORS_ALLOW_METHODS` | `*` | Allowed methods |
| `HTTP_CORS_ALLOW_HEADERS` | `*` | Allowed headers |

**Database**:
| Variable | Default | Description |
|----------|---------|-------------|
| `DATABASE_URL` | `sqlite+aiosqlite:///./storage.sqlite3` | Database connection string |
| `DATABASE_ECHO` | `false` | Echo SQL queries |

**Git Storage**:
| Variable | Default | Description |
|----------|---------|-------------|
| `STORAGE_ROOT` | `~/.mcp_agent_mail_git_mailbox_repo` | Git archive path |
| `GIT_AUTHOR_NAME` | `mcp-agent` | Git commit author name |
| `GIT_AUTHOR_EMAIL` | `mcp-agent@example.com` | Git commit author email |
| `INLINE_IMAGE_MAX_BYTES` | `65536` | Max inline image size |
| `CONVERT_IMAGES` | `true` | Convert images |
| `KEEP_ORIGINAL_IMAGES` | `false` | Keep originals after conversion |

**LLM Integration**:
| Variable | Default | Description |
|----------|---------|-------------|
| `LLM_ENABLED` | `true` | Enable LLM features |
| `LLM_DEFAULT_MODEL` | `gpt-5-mini` | Default model |
| `LLM_TEMPERATURE` | `0.2` | Generation temperature |
| `LLM_MAX_TOKENS` | `512` | Max tokens |
| `LLM_CACHE_ENABLED` | `true` | Cache LLM responses |
| `LLM_CACHE_BACKEND` | `memory` | `memory` or `redis` |
| `LLM_CACHE_REDIS_URL` | `` | Redis URL for cache |
| `LLM_COST_LOGGING_ENABLED` | `true` | Log LLM costs |

**Logging**:
| Variable | Default | Description |
|----------|---------|-------------|
| `LOG_LEVEL` | `INFO` | Log level |
| `LOG_RICH_ENABLED` | `true` | Rich console output |
| `LOG_JSON_ENABLED` | `false` | JSON structured logs |
| `LOG_INCLUDE_TRACE` | `false` | Include trace info |
| `TOOLS_LOG_ENABLED` | `true` | Log tool calls |

**OpenTelemetry**:
| Variable | Default | Description |
|----------|---------|-------------|
| `HTTP_OTEL_ENABLED` | `false` | Enable OpenTelemetry |
| `OTEL_SERVICE_NAME` | `mcp-agent-mail` | Service name |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | `` | OTLP endpoint |

**File Reservations**:
| Variable | Default | Description |
|----------|---------|-------------|
| `FILE_RESERVATIONS_ENFORCEMENT_ENABLED` | `true` | Enforce reservations |
| `FILE_RESERVATIONS_CLEANUP_ENABLED` | `false` | Auto-cleanup stale |
| `FILE_RESERVATIONS_CLEANUP_INTERVAL_SECONDS` | `60` | Cleanup interval |
| `FILE_RESERVATION_INACTIVITY_SECONDS` | `1800` | Inactivity timeout |
| `FILE_RESERVATION_ACTIVITY_GRACE_SECONDS` | `900` | Grace period |

**Acknowledgment TTL**:
| Variable | Default | Description |
|----------|---------|-------------|
| `ACK_TTL_ENABLED` | `false` | Enable ack TTL |
| `ACK_TTL_SECONDS` | `1800` | TTL duration |
| `ACK_TTL_SCAN_INTERVAL_SECONDS` | `60` | Scan interval |

**Ack Escalation**:
| Variable | Default | Description |
|----------|---------|-------------|
| `ACK_ESCALATION_ENABLED` | `false` | Enable escalation |
| `ACK_ESCALATION_MODE` | `log` | `log` or `file_reservation` |
| `ACK_ESCALATION_CLAIM_TTL_SECONDS` | `3600` | Claim TTL |
| `ACK_ESCALATION_CLAIM_EXCLUSIVE` | `false` | Exclusive claims |
| `ACK_ESCALATION_CLAIM_HOLDER_NAME` | `` | Claim holder name |

**Contacts**:
| Variable | Default | Description |
|----------|---------|-------------|
| `CONTACT_ENFORCEMENT_ENABLED` | `true` | Enforce contacts |
| `CONTACT_AUTO_TTL_SECONDS` | `86400` | Auto contact TTL |
| `CONTACT_AUTO_RETRY_ENABLED` | `true` | Auto retry contacts |

**Messaging**:
| Variable | Default | Description |
|----------|---------|-------------|
| `MESSAGING_AUTO_REGISTER_RECIPIENTS` | `true` | Auto-register recipients |
| `MESSAGING_AUTO_HANDSHAKE_ON_BLOCK` | `true` | Auto handshake on block |
| `AGENT_NAME_ENFORCEMENT_MODE` | `coerce` | `strict`, `coerce`, or `always_auto` |

**Retention & Quotas**:
| Variable | Default | Description |
|----------|---------|-------------|
| `RETENTION_REPORT_ENABLED` | `false` | Enable retention reports |
| `RETENTION_REPORT_INTERVAL_SECONDS` | `3600` | Report interval |
| `RETENTION_MAX_AGE_DAYS` | `180` | Max message age |
| `RETENTION_IGNORE_PROJECT_PATTERNS` | `demo,test*,...` | Ignored patterns |
| `QUOTA_ENABLED` | `false` | Enable quotas |
| `QUOTA_ATTACHMENTS_LIMIT_BYTES` | `0` | Attachment limit (0=unlimited) |
| `QUOTA_INBOX_LIMIT_COUNT` | `0` | Inbox limit (0=unlimited) |

**Metrics**:
| Variable | Default | Description |
|----------|---------|-------------|
| `TOOL_METRICS_EMIT_ENABLED` | `false` | Emit tool metrics |
| `TOOL_METRICS_EMIT_INTERVAL_SECONDS` | `60` | Emit interval |

**Project Identity**:
| Variable | Default | Description |
|----------|---------|-------------|
| `APP_ENVIRONMENT` | `development` | Environment name |
| `WORKTREES_ENABLED` | `false` | Enable worktree support |
| `GIT_IDENTITY_ENABLED` | `false` | Enable git identity |
| `PROJECT_IDENTITY_MODE` | `dir` | `dir`, `git-remote`, `git-common-dir`, `git-toplevel` |
| `PROJECT_IDENTITY_REMOTE` | `origin` | Remote for identity |

## Usage

```bash
make build       # Build image
make start       # Build and run container
make stop        # Stop container
make restart     # Restart container
make logs        # View container logs
make status      # Check container and registration status
make register    # Register with Claude Code
make unregister  # Remove from Claude Code
make clean       # Stop and remove image
```

## Notes

- This server has its own HTTP transport at `/mcp/` - does not need mcp-proxy
- Healthcheck available at `/health/liveness`
- Localhost connections allowed without auth by default
