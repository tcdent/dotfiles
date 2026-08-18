-- Neo-tree specific configuration

-- Neo-tree's own watcher (use_libuv_file_watcher) is left off: it is fs_event
-- only, non-recursive, and fails silently to a trace log. filewatch drives the
-- refresh instead, so the tree stays live without a second watcher.
require("filewatch").subscribe(vim.fn.getcwd(), function()
  pcall(require("neo-tree.sources.manager").refresh, "filesystem")
end)

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
