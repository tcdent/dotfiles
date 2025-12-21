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
      rustfmt = {
        overrideCommand = { 'rustup', 'run', 'nightly', 'rustfmt', '--edition', '2021', '--config-path', vim.fn.expand('~/.config/rustfmt/rustfmt.toml') },
      },
    },
  },
  on_attach = function(client, bufnr)
    client.server_capabilities.semanticTokensProvider = nil
    -- Format on save with rustfmt
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
    })
  end,
})
vim.lsp.enable('rust_analyzer')
