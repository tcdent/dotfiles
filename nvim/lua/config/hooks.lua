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
