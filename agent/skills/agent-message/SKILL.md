---
name: agent-message
description: Coordinate with other Claude Code instances via tmux. Discover peers, send messages, delegate tasks, run shell commands in other panes, and check on progress. Multiple Claudes often work simultaneously across projects and roles — this skill is how they find each other and collaborate. Also useful for running commands in non-Claude tmux panes (build servers, logs, test runners, etc.).
---

# Agent Messaging

## Overview

You are one of potentially many Claude Code instances running simultaneously in
tmux. Each instance may be working on a different project, a different part of
the same project, or a specialized role (backend, frontend, infra, data, etc.).

Tmux is the shared environment — it's how you discover peers, send messages,
delegate tasks, and run commands across the system. Every Claude instance has
access to this skill, so coordination works as long as everyone follows the
same conventions.

Use the `agent-message` CLI for all coordination. It handles identity,
discovery, message escaping, and delivery. Do not use raw `tmux send-keys`
for messaging — always go through `agent-message send`.

## Addressing

Each Claude lives in a tmux pane with a unique address: `session:window.pane`.

Examples: `cat:2.1`, `cat:2.6`, `agentexec:2.1`

**The pane number is your identity.** Multiple Claudes often share the same
tmux window, so window names don't distinguish between them. Use short names
based on the session and pane number:

- `foo 1` or `foo:2.1` — pane 1 in the foo session
- `foo 6` or `foo:2.6` — pane 6 in the foo session
- `bar 1` or `bar:2.1` — pane 1 in the bar session

When the user or another Claude refers to "foo 6" or "pane 6", they mean
`foo:2.6`. When you identify yourself, use this convention.

## Finding Your Own Address

```bash
agent-message whoami
```

Output: your identity, e.g. `mgmt.arch@a10k.internal` or `win10.setup@slomp.internal` (the domain varies per host — see the `agent-identity` skill). Falls back to your tmux address like `foo:2.6` if your pane isn't tagged with an identity.

## Discovery

Find all panes in your tmux session:

```bash
agent-message dir workspace
```

Find all panes across all sessions:

```bash
agent-message dir global
```

Example output:
```
  foo:2.1                              claude
  foo:2.2                              bash
  foo.backend@a10k.internal            claude (you)
  foo.frontend@a10k.internal           claude
  foo:2.6                              bash
  foo:2.9                              nvim
```

Identities may also appear under different host domains (`@slomp.internal`, etc.) depending on where peers are running. `agent-message dir network` fans out over SSH to list peers on other hosts too.

The directory shows all panes — tagged with their identity when present,
else their tmux address. `(you)` marks your pane.

**Run `dir` once at the start of a conversation** to orient yourself. It
tells you your own address and who else is around.

## Sending a Message

```bash
agent-message send <address> "<message>"
```

The command handles:
- **Sender identity** — automatically prepends `[your:address]` to the message
- **Escaping** — validates and escapes special characters for safe delivery
- **Submission** — sends the message + a trailing Enter to guarantee delivery

Example:
```bash
agent-message send foo.backend@a10k.internal "We need the lock_key feature for per-user task serialization. Can you read the worker pool and propose an implementation? Reply to me."
```

The recipient sees:
```
[foo.frontend@a10k.internal->foo.backend@a10k.internal] We need the lock_key feature for per-user task serialization. Can you read the worker pool and propose an implementation? Reply to me.
```

### Multiline Messages

Multiline messages work naturally:
```bash
agent-message send foo.backend@a10k.internal "Summary of changes:
- Added lock_key parameter to pool.add_task()
- Tasks with the same lock_key are serialized
- Different lock_keys run in parallel
Please review and let me know if this matches your needs."
```

### Long Messages and Attachments

If your message is more than a few lines write a tmp file and `$(cat ...)` it into the message body. This helps with difficult shell escapes as well. Drop your files in `/tmp/agent-message/<your.username>/<string>.txt` so that the other agent on the system can read it. Include a brief sunnary prefix along with the detailed message body.
```bash
agent-message send foo.backend@a10k.internal "Updated specs for the product refactor:
- I am concerned about the viabiilty of Feature A.
- The Feature B spec is well grounded in existing conventions.
- Still waiting for your response on my previous message.

Attached: /tmp/agent-message/your.username/a-descriptive-name-this-is-your-folder-it-wont-collide.txt
```

This contains a few benefits: The human can see the summary of your message without becoming overwhelmed with details. The message stays as a record of your exchange. You do not need to compose multiple messages in order to convey detailed thoughts. You can use native read/write/edit tools. The attachment can easily be forwarded to another agent without the need for re-generation.

### Backticks

`bash` executes backticks. If you want to include them in your message, do it in an attachment.

### Error Handling

The command returns an error if:
- The target session or pane doesn't exist
- The message contains escape sequences that can't be safely sent
- You're not running inside tmux

## Running Commands in Other Panes

For non-messaging interactions (restarting services, checking logs), use
raw tmux commands directly:

```bash
# Restart the worker in pane 4
tmux send-keys -t foo:2.4 C-c
tmux send-keys -t foo:2.4 "uv run python -m worker" Enter

# Check API logs in pane 3
tmux capture-pane -t foo:2.3 -p | tail -10
```

## Conventions

- **Run `agent-message dir` first** — orient yourself before sending messages.
  Pane assignments can change between sessions. Never assume you're in the
  same pane as last time.
- **Pane number is identity** — don't rename windows; use pane addresses
- **Be self-contained** — the recipient has no context about your conversation
- **One message, one task** — don't send multi-part requests
- **Request replies explicitly** — tell them to reply to you if you want a
  response
- **Don't poll or check on other agents** — send your message and move on.
  They will reach out to you when they have something. This is always the
  case. Don't capture their pane to check progress.
- **All Claudes have this skill** — you can assume the recipient knows
  the protocol
- **Stay within your project** — only communicate with Claudes working on
  the same project unless the user explicitly asks you to coordinate
  cross-project
- **Messages are for coordination, not work-of-record** — milestones,
  design decisions, post-mortems, blockers all belong in ticket comments
  (see the `agent-tracker` skill). Messages are the phone call; comments
  are the email.
