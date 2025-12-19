# MCP Agent Mail Tools

34 tools total. ~46k characters / ~11.5k tokens in docstrings alone.

Source: `src/mcp_agent_mail/app.py` in https://github.com/Dicklesworthstone/mcp_agent_mail

## Tools by Docstring Size (largest first)

| Tool | Line | DocLines | Chars |
|------|-----:|---------:|------:|
| `macro_contact_handshake` | 5120 | 120 | 5662 |
| `send_message` | 3314 | 95 | 4292 |
| `register_agent` | 3072 | 66 | 2979 |
| `macro_file_reservation_cycle` | 5068 | 63 | 2624 |
| `respond_contact` | 4595 | 58 | 2557 |
| `reply_message` | 4202 | 61 | 2464 |
| `ensure_project` | 2992 | 60 | 2456 |
| `install_precommit_guard` | 5544 | 49 | 2154 |
| `uninstall_precommit_guard` | 5570 | 49 | 2154 |
| `file_reservation_paths` | 5594 | 49 | 2154 |
| `create_agent_identity` | 3237 | 44 | 1955 |
| `summarize_thread` | 5373 | 38 | 1400 |
| `list_contacts` | 4660 | 30 | 1375 |
| `health_check` | 2943 | 37 | 1272 |
| `release_file_reservations` | 5779 | 34 | 1198 |
| `fetch_inbox` | 4712 | 29 | 1157 |
| `search_messages` | 5259 | 38 | 1123 |
| `set_contact_policy` | 4689 | 32 | 1103 |
| `acknowledge_message` | 4862 | 30 | 1026 |
| `request_contact` | 4454 | 24 | 943 |
| `mark_message_read` | 4793 | 27 | 918 |
| `whois` | 3180 | 24 | 895 |
| `renew_file_reservations` | 6043 | 21 | 739 |
| `force_release_file_reservation` | 5875 | 7 | 375 |
| `macro_start_session` | 4942 | 4 | 183 |
| `ensure_product` | 6352 | 6 | 181 |
| `macro_prepare_thread` | 5005 | 4 | 179 |
| `acquire_build_slot` | 6200 | 3 | 145 |
| `fetch_inbox_product` | 6549 | 3 | 135 |
| `release_build_slot` | 6274 | 3 | 127 |
| `summarize_thread_product` | 6597 | 3 | 123 |
| `renew_build_slot` | 6245 | 3 | 107 |
| `search_messages_product` | 6487 | 3 | 99 |
| `products_link` | 6393 | 3 | 85 |

**Total: 46,339 chars (~11,584 tokens)**

## Tools by Category

### Core Messaging (essential)
| Tool | Chars | Description |
|------|------:|-------------|
| `send_message` | 4292 | Send message with attachments, threading, importance |
| `fetch_inbox` | 1157 | Get recent messages with filtering |
| `reply_message` | 2464 | Create threaded reply |
| `acknowledge_message` | 1026 | Mark message as acknowledged |
| `mark_message_read` | 918 | Mark message as read |
| `search_messages` | 1123 | Full-text search via FTS5 |
| `summarize_thread` | 1400 | Extract key points from conversation |

### Agent Identity (essential)
| Tool | Chars | Description |
|------|------:|-------------|
| `register_agent` | 2979 | Create/update agent identity |
| `whois` | 895 | Retrieve an agent's profile |
| `create_agent_identity` | 1955 | Create agent identity (alternate) |

### Project Setup (essential)
| Tool | Chars | Description |
|------|------:|-------------|
| `ensure_project` | 2456 | Create/retrieve project |
| `health_check` | 1272 | Server liveness check |

### Cross-Project Contact (optional)
| Tool | Chars | Description |
|------|------:|-------------|
| `request_contact` | 943 | Initiate contact with external agent |
| `respond_contact` | 2557 | Approve/deny contact request |
| `list_contacts` | 1375 | View contacts and pending requests |
| `set_contact_policy` | 1103 | Update messaging policy |
| `macro_contact_handshake` | 5662 | Bidirectional contact setup |

### File Reservations (optional)
| Tool | Chars | Description |
|------|------:|-------------|
| `file_reservation_paths` | 2154 | Declare advisory file leases |
| `release_file_reservations` | 1198 | Remove active leases |
| `force_release_file_reservation` | 375 | Clear stale leases |
| `renew_file_reservations` | 739 | Extend active leases |

### Pre-commit Guards (optional)
| Tool | Chars | Description |
|------|------:|-------------|
| `install_precommit_guard` | 2154 | Wire pre-commit hooks |
| `uninstall_precommit_guard` | 2154 | Remove pre-commit hooks |

### Build Slots (optional)
| Tool | Chars | Description |
|------|------:|-------------|
| `acquire_build_slot` | 145 | Reserve build slot |
| `renew_build_slot` | 107 | Extend lease |
| `release_build_slot` | 127 | Release slot |

### Product Management (optional)
| Tool | Chars | Description |
|------|------:|-------------|
| `ensure_product` | 181 | Create/retrieve product grouping |
| `products_link` | 85 | Associate project with product |
| `search_messages_product` | 99 | Search across product's projects |
| `fetch_inbox_product` | 135 | Unified inbox across product |
| `summarize_thread_product` | 123 | Summarize across product |

### Macros (optional)
| Tool | Chars | Description |
|------|------:|-------------|
| `macro_start_session` | 183 | Init project + register agent |
| `macro_prepare_thread` | 179 | Create thread with initial message |
| `macro_file_reservation_cycle` | 2624 | Reserve → work → release |

## Reduction Strategies

### Minimal Set (~12k chars, ~3k tokens)
Keep only core messaging + identity + project:
- `ensure_project`, `register_agent`, `whois`
- `send_message`, `fetch_inbox`, `reply_message`, `acknowledge_message`
- `health_check`

**Removes:** 26 tools, ~34k chars

### Medium Set (~20k chars, ~5k tokens)
Add search and basic macros:
- Minimal set +
- `search_messages`, `summarize_thread`
- `macro_start_session`

### Full Set minus Products/Build (~40k chars, ~10k tokens)
Remove only product management and build slots (9 tools, ~6k chars)
