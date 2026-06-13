---
name: agent-identity
description: Establish or claim an agent identity (like project.role@<host-domain>). Use when the user tells an agent who they are ("you are mgmt.arch"), when an agent needs to check whether it has an identity, or when restoring an identity on a new host. Also use on phrases like "register yourself," "claim an identity," or "adopt a name."
---

# Agent Identity

As a Claude Code agent you have a persistent identity. It's how you're addressed in chat, attributed on tickets, and recognized across every internal tool (Plane, chat, anything else that comes online). The same name everywhere.

## Identity format

`<project>.<role>@<host-domain>`

- `mgmt.arch@a10k.internal` — architecture on the mgmt project
- `growth.design@a10k.internal` — design on the growth project
- `win10.setup@slomp.internal` — windows setup agent running on a different host

`<project>` is the work context. `<role>` is what you do on it — `app`, `design`, `manager`, `arch`, `data`, `qa`, etc.

## Is this identity available?

Before registering, run `agent-message dir` — if your intended identity already appears as a live pane, it's in use. Pick a different name or ask the user. If it doesn't appear, it's free to claim (and if the registry says it's already taken from a prior run, `agent-register` will tell you and offer the restore path).

Your session name (the prompt bar / `/resume` list) shows your current identity. If it reads "Claude Code" or something generic, you don't have one yet.

## Adopting an identity

The user will tell you your identity (e.g. "you are mgmt.arch"). Run:

    agent-register mgmt.arch

That's the whole bootstrap. The command handles everything — credential setup, directory registration, and if you're in a Claude Code session, renaming your session to match. You don't need to know what's underneath.

## Restoring an identity

If the identity is already taken but you believe it's yours (new host, lost creds, fresh pane), run:

    agent-register --restore mgmt.arch

This preserves your history — tickets, comments, audit trail, all of it stays attributed to you. Only use `--restore` if you're certain the identity belongs to you. It overwrites the existing password.

## That's the whole skill

Everything downstream (messaging other agents, any tool integration) builds on top of this. When in doubt, if you have an identity and the session name matches, you're ready to work.

The most common command you will use with this is `agent-message`, you may want to check out that skill next if you are part of a collaborative team. 
