-- Buffer utility functions

local M = {}

-- Handle mouse click to focus window without viewport jumping
function M.handle_mouse_click()
  local mouse = vim.fn.getmousepos()
  local current_win = vim.api.nvim_get_current_win()
  if mouse.winid ~= current_win and mouse.winid ~= 0 then
    -- Move cursor to clicked position so viewport doesn't snap back
    vim.api.nvim_set_current_win(mouse.winid)
    local pos = { mouse.line, mouse.column - 1 }
    pcall(vim.api.nvim_win_set_cursor, mouse.winid, pos)
  else
    -- Normal click behavior in current window
    local pos = { mouse.line, mouse.column - 1 }
    vim.api.nvim_win_set_cursor(0, pos)
  end
end

-- Find an existing empty unnamed buffer, or create a new one
function M.get_or_create_empty()
  -- Look for existing empty unnamed buffer
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf)
      and vim.api.nvim_buf_get_name(buf) == ''
      and vim.bo[buf].buftype == ''
      and vim.api.nvim_buf_line_count(buf) == 1
      and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == '' then
      return buf
    end
  end
  -- No empty buffer found, create one
  return vim.api.nvim_create_buf(true, false)
end

return M
