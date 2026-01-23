# nvim config

## Keybindings

Leader key is `Space`.

### Files & Navigation
- `<leader>e` - Toggle file browser (neo-tree)
- `<leader>ff` - Find files (telescope)
- `<leader>fg` - Live grep (telescope)
- `<leader>fb` - Browse open buffers (telescope)

### Buffers
- `<leader>]` - Next buffer
- `<leader>[` - Previous buffer
- `<leader>x` - Close buffer (cycles to previous)
- `<leader>n` - New/empty buffer

### Windows
- `<leader>t` - New split right
- `<leader>T` - New split left
- `<leader>w` + `h/j/k/l` - Move between windows
- `Ctrl-w =` - Equalize window sizes
- `Ctrl-w q` - Close window

### Git
- `<leader>d` - Open diff view
- `<leader>D` - Close diff view

### LSP (Python, Rust)
- `gd` - Go to definition
- `gr` - Find references (via Telescope)
- `K` - Hover docs
- `<leader>rn` - Rename symbol
- `<leader>v` - Show diagnostic with AI explanation (requires `ANTHROPIC_API_KEY` in `~/.env`)

## Vim Essentials

### Movement
- `0` - Start of line
- `$` - End of line
- `^` - First non-whitespace
- `Ctrl-d` / `Ctrl-u` - Half page down/up
- `}` / `{` - Next/previous paragraph
- `]` / `[` - Next/previous code block
- `10j` / `10k` - Jump 10 lines down/up

### Editing
- `u` - Undo
- `Ctrl-r` - Redo
- `D` - Delete to end of line

### Search
- `*` - Find next occurrence of word under cursor
- `#` - Find previous occurrence
- `n` / `N` - Next/previous match

### Find & Replace (cgn)
1. `*` on the word to search
2. `cgn` to change next match
3. Type new text, `Esc`
4. `.` to repeat, `n` to skip

### Visual Mode
- `v` - Character selection
- `V` - Line selection
- `Ctrl-v` - Block selection
- Then use motions (`j`, `k`, `w`, etc.) to extend
- `d` to delete, `y` to yank, `c` to change
- `>` / `<` - Indent / dedent
- `gc` - Toggle comment

## First-Time Setup

### GitHub Copilot
Run `:Copilot setup` to authenticate with GitHub.

## Git Commits

When `git commit` opens in nvim via `nvimw`, use `:w | bd` to save and close (not just `:wq`).
