-- Rust-specific configuration

-- LSP setup (Neovim 0.11+ native)
vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = true,
      check = {
        command = 'clippy',
      },
      cargo = {
        allFeatures = true,
      },
    },
  },
  on_attach = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})
vim.lsp.enable('rust_analyzer')
