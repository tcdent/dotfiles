-- Markdown-specific configuration (mdx.nvim gives .mdx its own filetype)

-- Wrap for prose
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "mdx" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true  -- wrap at word boundaries
  end,
})
