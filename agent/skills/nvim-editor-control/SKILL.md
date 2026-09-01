---
name: nvim-editor-control
description: Show code to the user inside their running Neovim instead of pasting it into the terminal — open a file at a line range, lay files out in columns, annotate specific lines, drive the diff view, and read back what they are looking at. Use during code review, when explaining a change, when pointing at a specific line, or when the user says "show me" / "what am I looking at" / "open that". Requires the `agent-nvim` shortcut and runs only from inside the owning tmux session.
---

# Driving the user's Neovim

The user works in tmux: pane 1 runs `nvim --listen /tmp/nvim-<session>.sock .`,
and agents run in the other panes of the same session. That socket is the full
RPC surface, so anything Lua can do inside the editor is reachable from your
shell.

`~/.config/nvim/lua/agent.lua` wraps the useful operations, and
`~/.config/bin/agent-nvim` wraps the calling convention:

```bash
agent-nvim status
agent-nvim focus nvim/lua/agent.lua 34 34 68
agent-nvim note nvim/init.lua 131 "this is the load-bearing line"
```

`agent-nvim --help` prints usage and greps the current function list out of
`agent.lua`, so it cannot drift from the module. **Run it first** rather than
trusting this document's list.

## Why this is worth doing

Position and context are expensive to convey in a terminal and free to convey in
the editor. "Line 131 of init.lua" makes the user hold a number in their head;
`agent-nvim focus nvim/init.lua 131 131 140` just shows them.

It is also bidirectional. The user's cursor and visual selection arrive in your
context automatically through the IDE integration (they run `/ide` once). So
they can select a line, say "why is this here", and you already have it — and
`agent-nvim where` fills in what the selection alone does not tell you.

## The functions

Every one returns a description of what it did, so **you never need a second
call to confirm it worked.** Read the return value; do not follow up with a
status query.

| | |
|---|---|
| `status` | cwd in both scopes, unsaved buffers, windows, filewatch subscriptions. Cheapest way to confirm the connection. |
| `focus PATH [LINE] [FIRST LAST]` | open, put the cursor on LINE, highlight FIRST..LAST |
| `columns SPEC...` | vertical columns, left to right, focus the last. Specs are `path`, `path:line`, `path:line:first-last` |
| `note PATH LINE TEXT` | short remark at end of line |
| `note_block PATH LINE TEXT` | multi-line block below the line, like a review comment |
| `clear` | remove every mark this module placed |
| `diff [REV]` | open the diff view; REV takes the same arguments as `:D` |
| `diff_files [1]` | list files in the diff; pass `1` to drop untracked |
| `diff_file PATH` | show one file in the open diff view |
| `where` | current file, cursor, selection, **which side of a diff**, and surrounding context |

Highlights and notes are extmarks, not text. The buffer is never modified,
nothing can be written to disk by accident, and they survive both a diff refresh
and a full content reload. `clear` removes them.

## How to use it well

**Annotate sparingly.** `note_block` owns its own screen rows, so a few notes
push the real code off screen. Two or three anchored remarks per screen is the
ceiling. Use it for the load-bearing line, the tradeoff you cannot resolve, the
assumption you made — not as a general channel for what you have to say. The
terminal is better for anything longer.

**`diff_files 1` almost always.** In a repo with untracked files the unfiltered
list is dominated by files git has never seen. In this one it is 74 entries
versus 5.

**`clear` before a new topic**, or old annotations accumulate against code they
no longer describe. Marks are anchored to line positions, not content: if the
line they point at is deleted or rewritten, the note survives pointing at
whatever now occupies that position. A stale note is worse than no note.

**Reach for `where` when a selection does not make sense.** In a diff, the user
may have selected in the *index/HEAD* pane, where line numbers do not match the
working tree. `where` reports `[diff:working-tree]` or `[diff:index-or-HEAD]`
explicitly. If selected text does not match what you read at that line, this is
why.

## Constraints and failure modes

**Only works from inside the owning tmux session.** The socket is derived from
`tmux display -p '#S'`, exactly as `nvims` does. You are almost certainly inside
it — check `$TMUX` before assuming otherwise.

**Never resolve paths against `vim.fn.getcwd()`.** It returns the *window-local*
directory when one is set, which differs per window. `agent.lua` uses
`getcwd(-1, -1)` and relative paths resolve against the global cwd.

**`:edit` does not fail on a missing path** — it silently opens an empty "new
file" buffer, so a typo looks like success. Every path in `agent.lua` is checked
with `filereadable()` first. If you write new editor code, do the same; this is
the guard that matters, not any rule about absolute paths.

**Prefer `vim.cmd` in a `pcall` over `--remote-send`.** A bad command sent as
keystrokes can leave the editor at a `Press ENTER` prompt, which blocks every
subsequent socket call — the whole channel wedges, not just that command. If
calls start timing out, check with
`tmux capture-pane -p -t <session>:1.1 | tail -5` and clear it with
`tmux send-keys -t <session>:1.1 Enter`.

**Errors raised inside scheduled callbacks escape `pcall`.** Anything
asynchronous (notably `Neotree show`) can fail after your call returns. If you
extend `agent.lua`, avoid async plugin commands in the middle of a window
rearrangement rather than wrapping them hopefully.

**`columns` refuses when any buffer is modified**, since it closes windows. Save
first or use `focus`.

## Extending it

`agent.lua` is meant to grow as better ways to work together are found. Two
rules keep it usable:

- every function returns a human-readable description of what it did
- guardrails live inside the function, not at the call site

Deliberately absent: anything that mutates git state. Staging from the diff
panel is reachable and would close review into commit, but it should be added
knowingly rather than arriving as a side effect.
