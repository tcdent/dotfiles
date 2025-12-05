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
- `<leader>x` - Close buffer

### Windows
- `<leader>t` - New vertical split (reuses empty buffer)
- `<leader>w` + `h/j/k/l` - Move between windows
- `Ctrl-w q` - Close window

### Git
- `<leader>d` - Open diff view
- `<leader>D` - Close diff view

### LSP (Python)
- `gd` - Go to definition
- `gr` - Find references
- `K` - Hover docs
- `<leader>rn` - Rename symbol
- `<leader>l` - Show diagnostic message

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

## Git Commits

When `git commit` opens in nvim via `nvimw`, use `:w | bd` to save and close (not just `:wq`).
