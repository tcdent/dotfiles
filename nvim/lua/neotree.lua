-- Neo-tree specific configuration

-- Prevent horizontal scrolling
vim.api.nvim_create_autocmd("FileType", {
  pattern = "neo-tree",
  callback = function()
    vim.opt_local.wrap = true
    -- Disable horizontal scroll keys
    vim.keymap.set('n', 'zl', '<Nop>', { buffer = true })
    vim.keymap.set('n', 'zh', '<Nop>', { buffer = true })
    vim.keymap.set('n', 'zL', '<Nop>', { buffer = true })
    vim.keymap.set('n', 'zH', '<Nop>', { buffer = true })
    vim.keymap.set('n', '<ScrollWheelLeft>', '<Nop>', { buffer = true })
    vim.keymap.set('n', '<ScrollWheelRight>', '<Nop>', { buffer = true })
  end,
})
