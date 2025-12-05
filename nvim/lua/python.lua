-- Python-specific configuration

-- LSP setup (Neovim 0.11+ native)
vim.lsp.config('pyright', {
  settings = {
    python = {
      venvPath = ".",
      venv = ".venv",
    },
  },
})
vim.lsp.enable('pyright')

-- Format with ruff on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.py",
  callback = function()
    -- Save cursor and view position
    local cursor = vim.api.nvim_win_get_cursor(0)
    local view = vim.fn.winsaveview()

    vim.cmd("silent !ruff format " .. vim.fn.expand("%"))
    vim.cmd("silent !ruff check --fix " .. vim.fn.expand("%"))
    vim.cmd("edit")

    -- Restore cursor and view position
    vim.fn.winrestview(view)
    pcall(vim.api.nvim_win_set_cursor, 0, cursor)
  end,
})
