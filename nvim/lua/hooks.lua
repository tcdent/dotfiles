-- Global hooks that are called on specific events

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
