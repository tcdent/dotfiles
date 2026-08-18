-- Python-specific configuration

-- Refresh LSP diagnostics for externally edited files. The buffer itself is
-- reloaded by the checktime subscriber in init.lua; this nudges the server so
-- its diagnostics match the new contents.
require("filewatch").subscribe(vim.fn.getcwd(), function(paths)
  for _, path in ipairs(paths) do
    for _, client in pairs(vim.lsp.get_clients({ name = "ty" })) do
      client:notify("textDocument/didSave", {
        textDocument = { uri = vim.uri_from_fname(path) },
      })
    end
  end
end, { "suffix", "py" })

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
