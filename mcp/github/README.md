# GitHub MCP Server

Local containerized instance of [GitHub's official MCP server](https://github.com/github/github-mcp-server) via Streamable HTTP.

## Setup

1. Authenticate with GitHub CLI: `gh auth login`
2. Build the proxy base image: `cd ../proxy && make build`
3. Copy `.env.example` to `.env` and configure port/scope/tools
4. Build and start: `make start`
5. Register with Claude Code: `make register`

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

## Configuration

Configure in `.env`:

```bash
GITHUB_MCP_PORT=7100           # Required - host port
GITHUB_MCP_SCOPE=user          # Required - claude registration scope
GITHUB_TOOLSETS=repos,issues   # Optional - enable toolset groups
GITHUB_TOOLS=get_me,get_gist   # Optional - enable individual tools
```

Authentication uses `gh auth token` - no PAT management needed.

### Toolsets

| Toolset | Description |
|---------|-------------|
| `repos` | Repository and file operations |
| `issues` | Issue management |
| `pull_requests` | PR handling |
| `actions` | GitHub Actions workflows |
| `code_security` | Code scanning alerts |
| `secret_protection` | Secret scanning alerts |
| `dependabot` | Dependency vulnerability alerts |
| `notifications` | Notification management |
| `discussions` | Discussion threads |
| `gists` | Gist operations |
| `projects` | Project board management |
| `labels` | Label management |
| `users` | User search |
| `orgs` | Organization search |
| `stargazers` | Star/unstar repositories |
| `security_advisories` | Security advisory lookup |
| `context` | Current user/team info |
| `git` | Low-level Git operations |
| `experiments` | Experimental features |

## Available Tools

### repos
| Tool | Description |
|------|-------------|
| `get_file_contents` | Access file or directory contents |
| `create_or_update_file` | Add or modify files via API |
| `delete_file` | Remove file from repository |
| `push_files` | Commit multiple files |
| `search_code` | Query repository contents |
| `search_repositories` | Find repositories |
| `create_repository` | Initialize new repository |
| `fork_repository` | Create repository copy |
| `create_branch` | Create new branch |
| `list_branches` | Display repository branches |
| `list_commits` | Show commit history |
| `get_commit` | Retrieve commit details |
| `list_tags` | Show repository tags |
| `get_tag` | Retrieve tag information |
| `list_releases` | Display release versions |
| `get_latest_release` | Retrieve newest version |
| `get_release_by_tag` | Access specific release version |

### issues
| Tool | Description |
|------|-------------|
| `list_issues` | Display repository issues |
| `search_issues` | Query issues with advanced filters |
| `issue_read` | Get issue details or components |
| `issue_write` | Create or modify issues |
| `add_issue_comment` | Post comment on issue |
| `sub_issue_write` | Manage subtask relationships |
| `assign_copilot_to_issue` | Delegate issue to AI assistant |
| `list_issue_types` | Show custom issue types available |

### pull_requests
| Tool | Description |
|------|-------------|
| `list_pull_requests` | Display PRs with filtering |
| `search_pull_requests` | Query PRs with advanced filters |
| `pull_request_read` | Get PR details or components |
| `create_pull_request` | Open new PR with changes |
| `update_pull_request` | Modify PR metadata |
| `update_pull_request_branch` | Sync PR with base branch |
| `merge_pull_request` | Combine PR into base branch |
| `pull_request_review_write` | Create or submit reviews |
| `add_comment_to_pending_review` | Post review comment |
| `request_copilot_review` | Request AI code review |

### actions
| Tool | Description |
|------|-------------|
| `list_workflows` | Show available workflows |
| `list_workflow_runs` | Display workflow execution history |
| `get_workflow_run` | Retrieve workflow execution details |
| `get_workflow_run_usage` | View resource consumption |
| `get_workflow_run_logs` | Access complete workflow logs |
| `list_workflow_jobs` | Display jobs within a workflow |
| `get_job_logs` | Access logs for individual jobs |
| `list_workflow_run_artifacts` | Show generated artifacts |
| `download_workflow_run_artifact` | Retrieve build output files |
| `rerun_workflow_run` | Re-execute entire workflow |
| `rerun_failed_jobs` | Re-execute only failed jobs |
| `cancel_workflow_run` | Stop an active workflow |
| `delete_workflow_run_logs` | Remove logs from completed workflow |

### code_security
| Tool | Description |
|------|-------------|
| `list_code_scanning_alerts` | Display code scanning results |
| `get_code_scanning_alert` | Retrieve alert details |

### secret_protection
| Tool | Description |
|------|-------------|
| `list_secret_scanning_alerts` | Show detected secrets |
| `get_secret_scanning_alert` | Retrieve exposed credential details |

### dependabot
| Tool | Description |
|------|-------------|
| `list_dependabot_alerts` | Show dependency security alerts |
| `get_dependabot_alert` | Retrieve vulnerability details |

### notifications
| Tool | Description |
|------|-------------|
| `list_notifications` | Display user notifications |
| `get_notification_details` | Retrieve notification information |
| `dismiss_notification` | Mark notification as read/done |
| `mark_all_notifications_read` | Clear notification inbox |
| `manage_notification_subscription` | Control notification preferences |
| `manage_repository_notification_subscription` | Set repo notification settings |

### discussions
| Tool | Description |
|------|-------------|
| `list_discussions` | Display discussion threads |
| `list_discussion_categories` | Show available categories |
| `get_discussion` | Retrieve discussion details |
| `get_discussion_comments` | Access comments in discussions |

### gists
| Tool | Description |
|------|-------------|
| `list_gists` | Display user's gists |
| `get_gist` | Retrieve gist contents |
| `create_gist` | Create code snippet |
| `update_gist` | Modify gist contents |

### projects
| Tool | Description |
|------|-------------|
| `list_projects` | Show available projects |
| `get_project` | Retrieve project details |
| `list_project_items` | Display project board items |
| `get_project_item` | Get item details with field values |
| `add_project_item` | Add issue/PR to project |
| `update_project_item` | Modify item field values |
| `delete_project_item` | Remove item from project |
| `list_project_fields` | Show project field definitions |
| `get_project_field` | Access field configuration |

### labels
| Tool | Description |
|------|-------------|
| `list_label` | Show repository labels |
| `get_label` | Retrieve label information |
| `label_write` | Create, update, or delete labels |

### users
| Tool | Description |
|------|-------------|
| `search_users` | Find users by criteria |

### orgs
| Tool | Description |
|------|-------------|
| `search_orgs` | Find organizations by criteria |

### stargazers
| Tool | Description |
|------|-------------|
| `list_starred_repositories` | Show starred repositories |
| `star_repository` | Mark repository as favorite |
| `unstar_repository` | Remove favorite marking |

### security_advisories
| Tool | Description |
|------|-------------|
| `list_global_security_advisories` | Display known vulnerabilities |
| `get_global_security_advisory` | Retrieve vulnerability info |
| `list_repository_security_advisories` | Display repo advisories |
| `list_org_repository_security_advisories` | Show org advisories |

### context
| Tool | Description |
|------|-------------|
| `get_me` | Retrieve authenticated user profile |
| `get_teams` | Display user's team memberships |
| `get_team_members` | List members of a GitHub team |

### git
| Tool | Description |
|------|-------------|
| `get_repository_tree` | Access repository file structure |
