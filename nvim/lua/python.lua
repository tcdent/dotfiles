-- Python-specific configuration

-- Refresh LSP diagnostics when regaining focus (for external edits)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  pattern = "*.py",
  callback = function()
    vim.defer_fn(function()
      for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
        client.notify("textDocument/didSave", {
          textDocument = { uri = vim.uri_from_bufnr(0) }
        })
      end
    end, 100)
  end,
})

-- LSP setup (Neovim 0.11+ native)
vim.lsp.config('ty', {
  settings = {
    ty = {
      diagnosticMode = 'openFilesOnly',
    },
  },
  on_attach = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})
vim.lsp.enable('ty')

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
