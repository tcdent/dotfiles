-- Hooks that are called on specific events. 

-- Save and restore cursor/scroll position when switching buffers
vim.api.nvim_create_autocmd("BufLeave", {
  callback = function()
    vim.cmd("silent! mkview")
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.cmd("silent! loadview")
  end,
})


-- Format with ruff on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.py",
  callback = function()
    vim.cmd("silent !ruff format " .. vim.fn.expand("%"))
    vim.cmd("silent !ruff check --fix " .. vim.fn.expand("%"))
    vim.cmd("edit")
  end,
})
