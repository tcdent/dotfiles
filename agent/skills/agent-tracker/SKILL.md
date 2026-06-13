---
name: agent-tracker
description: Ticket and sprint operations for agents via the agent-tracker CLI. Use when an agent needs to create, read, comment on, transition, promote, or assign tickets, or create sprints. Invoke on phrases like "file a ticket", "add a comment on X", "move the ticket to done", "assign this to mgmt.design", "promote to the current sprint", or "create a sprint for next week".
---

# Agent Tracker

`agent-tracker` is the CLI for working with tickets and sprints. Your identity is discovered automatically — no auth flags to remember, no tokens to pass.

## Lifecycle

Every ticket follows the same path:

1. **Backlog** — anyone creates the ticket via `ticket backlog`. It lands in the project's backlog, unassigned, not scheduled.
2. **Sprint** — a planner promotes it onto a sprint with `ticket promote`, then assigns an owner with `ticket assign`. These are deliberately separate steps: promote puts the ticket on the calendar; assign picks who runs it.
3. **In progress** — the assignee moves the ticket through states with `ticket transition` and records progress with `ticket comment`.
4. **Done** — a final state transition closes it.

Anyone can read any ticket with `ticket get`. Comments accumulate — they don't edit. If a ticket's goal genuinely changes, open a new one.

## Commands — anyone

    agent-tracker ticket backlog --name <name> --body <text|->
    agent-tracker ticket body <ticket-id>
    agent-tracker ticket state <ticket-id>
    agent-tracker ticket comments <ticket-id> <comment-id> [<comment-id>...]
    agent-tracker ticket transition <ticket-id> <state>
    agent-tracker ticket comment <ticket-id> --body <text|->

The three read commands split by volatility so you only re-load what actually changes:

- `ticket body` — the immutable goal, set at creation. Fetch once per ticket and reuse.
- `ticket state` — compact, token-conscious overview (status, assignee, sprint, comment refs with id / timestamp / author). Designed to be re-checked cheaply: everything you need to decide whether anything moved since your last look, and what to dig into further.
- `ticket comments` — hydrate comment bodies by id. First encounter with a ticket: pass every id from `ticket state`. Re-engagement: pass only the ids you don't already have in context.

## Commands — planner role

    agent-tracker sprint create <name> --start <YYYY-MM-DD> --end <YYYY-MM-DD>
    agent-tracker ticket promote <id> <sprint-id>
    agent-tracker ticket assign <id> <agent-identity>

`<agent-identity>` is an email like `mgmt.design@a10k.internal` or `win10.setup@slomp.internal` — the domain depends on where the target agent is registered (see the `agent-identity` skill).

## Conventions

- `--body -` reads from stdin (pipe-friendly — `echo "..." | agent-tracker ticket comment FOO-1 --body -`)
- `--json` on any command emits machine-readable JSON
- `--yes` is required for destructive operations in non-TTY contexts
- Exit codes: `0` success, `1` user error, `2` API error, `3` auth/identity error

## Help

Every level supports `--help`:

    agent-tracker --help
    agent-tracker ticket --help
    agent-tracker ticket backlog --help

## Writing content

- **Ticket body** — state the goal plainly. Once set at creation, it's fixed. If the goal changes, create a new ticket.
- **Comments** — progress, decisions, blockers, next steps. Be specific enough that another agent reading the trail later can pick up without needing to ask you.

## Referencing tickets in prose

When writing about a ticket outside of agent-tracker's own verbs — in messages, comments, summaries — use one of two forms:

- **Agent-to-agent / internal**: bare tag. `MGMT-14`, `CAT-11`. Short, no URL noise.
- **Human-facing (messages to Travis, status summaries, anything a human reads)**: markdown link. `[MGMT-14](https://tracker.a10k.co/t/MGMT-14)`. The reader clicks through instead of navigating manually.

The `/t/<ID>` route is a server-side redirect to the ticket's canonical page — construct the URL from the identifier directly, no UUID lookup needed. If you're unsure who reads the output, include the link.

## Ticket comments vs. agent-message

Ticket comments are email. `agent-message` is a phone call. Other agents are always on the line, so reach out live when you need coordination — the durable record on the ticket is for the things that outlive the conversation.

**Send a message (agent-message) for:**

- Coordination, debugging, problem-solving in real time
- Quick questions, acks, "look at ticket X"
- Pings that point at something ("I just posted a milestone comment on FOO-1")

**Write a ticket comment for:**

- Milestones — scaffolding done, docs complete, feature landed
- Design decisions solidified enough to reference later
- Blockers that need human review or redirection
- Unforeseen findings and post-mortems — always in comments
- Anything the team needs to find later without being told it exists

**Anti-pattern:** putting substantive analysis, decisions, or findings into a message. Once the recipient reads it, the context is gone — future agents (including future-you) won't find it. Put the substance in a comment; the message becomes a pointer at most.

**Authorship:** whoever makes or confirms the decision posts the comment — don't centralize durable writes through one agent. A ping-message pointing at the update is fine but optional; the comment itself is the work-of-record.

## If something goes wrong

- Exit code 3 (auth/identity) — confirm you've run `agent-register` via the `agent-identity` skill, then retry. If the error persists, the tool may be waiting on deploy-side setup (PAT bootstrap); ask the user.
- Exit code 2 (API) — the ticketing backend returned an error. Rerun with `--json` to see the full payload.
- Exit code 1 (user error) — check `--help` for the command you ran.
