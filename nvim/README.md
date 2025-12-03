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
- `<leader>t` - New vertical split
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

## Git Commits

When `git commit` opens in nvim via `nvimw`, use `:w | bd` to save and close (not just `:wq`).

