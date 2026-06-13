---
name: restore-history-from-file
description: Restore conversational context from a saved agent transcript file by extracting only user and assistant text turns, ignoring tool calls/results and internal thinking. Use when a user provides a Claude Code, Codex, or other agent history JSONL/file path and asks to resume, restore, or read prior conversation turns.
---

# Restore History From File

Recover conversation context from an on-disk agent transcript without polluting the restore with tool calls, tool results, screenshots, local-command metadata, or hidden reasoning.

Use this after `get-history-filename` locates a transcript, or when the user directly gives a history file path.

## Core Workflow

1. **Inspect the file first.**
   - Confirm it exists and note size/line count.
   - Read a few head/tail lines to identify the harness shape.

2. **Extract only text turns.**
   - Include top-level `type == "user"` and `type == "assistant"` entries.
   - Keep only actual message text:
     - `message.content` as a string.
     - `message.content[]` blocks where `type == "text"`.
   - Ignore:
     - assistant `thinking` blocks.
     - assistant `tool_use` blocks.
     - user `tool_result` blocks.
     - transcript metadata such as `system`, `attachment`, `file-history-snapshot`, `custom-title`, `agent-name`, `bridge-session`, `permission-mode`, `mode`, `queue-operation`, `last-prompt`.
     - local command artifacts unless the user explicitly wants them.

3. **Read in numbered chunks, not summaries.**
   - Number turns with `nl -ba`.
   - Page through ranges with `sed -n 'START,ENDp'`.
   - If the user asks to restore context, actually read all chunks. Do not summarize early and stop.
   - If a tool output truncates, re-read the affected smaller range.

4. **Only summarize after reading.**
   - Once all chunks are read, state that the transcript has been read and wait for the next instruction unless the user asked for a specific output.

## Claude Code JSONL Shape

Claude Code stores JSONL records with a top-level `type`. Conversation text is usually in:

```json
{
  "type": "user",
  "message": {
    "role": "user",
    "content": "text..."
  }
}
```

or:

```json
{
  "type": "assistant",
  "message": {
    "role": "assistant",
    "content": [
      {"type": "text", "text": "text..."},
      {"type": "tool_use", "id": "...", "name": "...", "input": {}},
      {"type": "thinking", "thinking": "..."}
    ]
  }
}
```

Tool results often appear as top-level `type == "user"` with list content blocks such as `{"type":"tool_result", ...}`. Do not include those in the restored conversation.

Skill injections and local-command transcripts may also appear as user text. They are real visible turns, but they are usually operational context rather than conversation. If the user says "extract user/assistant messages and ignore tools and thinking," include these only when they are text turns; if the user asks for clean human/assistant dialogue, filter obvious skill manuals and local-command caveats too.

## Preferred `jq` Extractor

This emits one line per visible text turn: role, a tab, then text with newlines escaped so chunking stays stable.

```bash
jq -r '
  select(.type == "user" or .type == "assistant")
  | .message.content as $c
  | if ($c|type) == "string" then
      .message.role + "\t" + ($c | gsub("\n"; "\\n"))
    elif ($c|type) == "array" then
      ([ $c[] | select(.type == "text") | .text ] | join("\n")) as $t
      | select($t|length > 0)
      | .message.role + "\t" + ($t | gsub("\n"; "\\n"))
    else
      empty
    end
' /path/to/transcript.jsonl
```

Count extracted text turns:

```bash
jq -r '
  select(.type == "user" or .type == "assistant")
  | .message.content as $c
  | if ($c|type) == "string" then
      .message.role + "\t" + ($c | gsub("\n"; "\\n"))
    elif ($c|type) == "array" then
      ([ $c[] | select(.type == "text") | .text ] | join("\n")) as $t
      | select($t|length > 0)
      | .message.role + "\t" + ($t | gsub("\n"; "\\n"))
    else
      empty
    end
' /path/to/transcript.jsonl | wc -l
```

Read chunks:

```bash
jq -r '...same filter...' /path/to/transcript.jsonl \
  | nl -ba \
  | sed -n '1,80p'
```

Then continue:

```bash
sed -n '81,160p'
sed -n '161,240p'
```

Prefer 40-80 turns per chunk. Use smaller chunks for very large turns or when output truncates.

## Python Fallback

Use this when `jq` is unavailable. If the environment uses `uv`, run as `uv run python`.

```bash
uv run python -c '
import json, sys
p = sys.argv[1]
for line in open(p, encoding="utf-8"):
    o = json.loads(line)
    if o.get("type") not in ("user", "assistant"):
        continue
    msg = o.get("message") or {}
    role = msg.get("role") or o.get("type")
    c = msg.get("content")
    parts = []
    if isinstance(c, str):
        parts = [c]
    elif isinstance(c, list):
        for b in c:
            if isinstance(b, dict) and b.get("type") == "text":
                parts.append(b.get("text", ""))
    text = "\n".join(x for x in parts if x and x.strip()).strip()
    if text:
        escaped = text.replace("\n", "\\n")
        print(f"{role}\t{escaped}")
' /path/to/transcript.jsonl
```

If `uv` fails because its cache is read-only, set a writable cache:

```bash
UV_CACHE_DIR=/tmp/uv-cache uv run python -c '...'
```

## Sanity Checks

Before reading all chunks:

```bash
wc -l /path/to/transcript.jsonl
head -n 5 /path/to/transcript.jsonl
tail -n 5 /path/to/transcript.jsonl
```

Count top-level record types:

```bash
jq -r '.type' /path/to/transcript.jsonl | sort | uniq -c
```

Count extracted roles:

```bash
jq -r '
  select(.type == "user" or .type == "assistant")
  | .message.role // .type
' /path/to/transcript.jsonl | sort | uniq -c
```

## Restoration Etiquette

- If the user says "read chunks" or "restore context," do not produce running summaries between chunks unless asked.
- Do not create a cleaned transcript file unless requested; reading chunks is often enough and avoids unnecessary files.
- If you do write an extracted transcript, put it in the current workspace or `/tmp`, and say exactly what filter was used.
- Preserve role labels and turn order.
- Correct yourself if you accidentally summarized instead of reading. Continue from the next unread chunk.

## Restoring Agent Identity

When the transcript clearly establishes the agent's identity and the user asks to restore it, use the `agent-identity` skill after restoring the conversation context. Register or restore the identity, then verify what the current pane advertises:

```bash
agent-message whoami
agent-message dir global
```

For Codex sessions, `agent-register` may queue `/rename`, but `agent-message` discovers live identities from the tmux `pane_title`. If `whoami` still falls back to a tmux address such as `uptime:2.1`, set the current pane title explicitly:

```bash
tmux select-pane -t "$TMUX_PANE" -T "project.role@host-domain"
```

Then re-run `agent-message whoami` and `agent-message dir global`; the directory should show the identity with `(you)`.

## Extending To Other Harnesses

For a new harness, first identify:

- record delimiter: JSONL, JSON array, SQLite, plain text.
- role fields: where user/assistant/system roles live.
- content variants: string, block array, markdown parts, tool parts.
- hidden/tool markers to exclude.
- resume metadata that should not be treated as dialogue.

Then adapt the same invariant: **chronological visible user/assistant text only, no tool calls/results, no internal reasoning, chunked with line numbers.**
