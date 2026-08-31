-- Global hooks that are called on specific events

-- mkview saves everything in 'viewoptions', which defaults to
-- "folds,cursor,curdir". curdir writes an `lcd <dir>` line into the view file,
-- so entering a buffer replays a window-local directory captured whenever that
-- buffer was last left -- possibly months and several projects ago. That is why
-- windows were silently ending up in ~/Work/agentexec and ~/Work/cat while the
-- global cwd stayed put, and why `:D` diffed the wrong repo. Keep folds and
-- cursor; drop the directory.
vim.opt.viewoptions:remove("curdir")

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
