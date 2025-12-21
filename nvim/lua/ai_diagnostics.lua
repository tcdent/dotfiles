-- AI-enhanced diagnostics using Claude API
local M = {}

-- Track current float window/buffer
local current_win = nil
local current_buf = nil
local original_win = nil
local original_view = nil

-- Read API key from ~/.env
local function get_api_key()
  local env_file = io.open(os.getenv("HOME") .. "/.env", "r")
  if not env_file then return nil end
  
  for line in env_file:lines() do
    local key = line:match('ANTHROPIC_API_KEY="([^"]+)"')
    if key then
      env_file:close()
      return key
    end
  end
  env_file:close()
  return nil
end

-- Get context around current line with line numbers
local function get_context(bufnr, line)
  local start_line = math.max(0, line - 5)
  local end_line = math.min(vim.api.nvim_buf_line_count(bufnr), line + 6)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
  
  local numbered_lines = {}
  for i, text in ipairs(lines) do
    local actual_line = start_line + i  -- 1-indexed line number
    local marker = (actual_line == line + 1) and " -->" or "    "
    table.insert(numbered_lines, string.format("%s %3d | %s", marker, actual_line, text))
  end
  
  return table.concat(numbered_lines, "\n")
end

-- Create highlight for AI text (white)
vim.api.nvim_set_hl(0, "AIDiagnosticText", { fg = "#D4D4D4" })

-- Update or create floating window with content
local function show_float(content, severity, update_only)
  local lines = {}
  local diagnostic_end_line = 0
  local found_separator = false
  
  -- Word wrap at 80 chars
  for line in content:gmatch("[^\n]*") do
    if line == "" then
      table.insert(lines, "")
      if not found_separator then
        diagnostic_end_line = #lines
        found_separator = true
      end
    else
      while #line > 80 do
        local wrap_at = line:sub(1, 80):match(".*()%s") or 80
        table.insert(lines, line:sub(1, wrap_at))
        line = line:sub(wrap_at + 1)
      end
      if #line > 0 then
        table.insert(lines, line)
      end
    end
  end
  
  local width = 85
  local height = math.min(20, #lines)
  
  -- Reuse existing buffer/window or create new
  if update_only and current_buf and vim.api.nvim_buf_is_valid(current_buf) then
    vim.api.nvim_buf_set_lines(current_buf, 0, -1, false, lines)
    if current_win and vim.api.nvim_win_is_valid(current_win) then
      vim.api.nvim_win_set_height(current_win, height)
    end
  else
    current_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(current_buf, 0, -1, false, lines)
    
    current_win = vim.api.nvim_open_win(current_buf, true, {
      relative = "cursor",
      row = 1,
      col = 0,
      width = width,
      height = height,
      style = "minimal",
      border = "rounded",
    })
    
    -- Close on any key
    local function close_float()
      if current_win and vim.api.nvim_win_is_valid(current_win) then
        vim.api.nvim_win_close(current_win, true)
      end
      -- Restore original scroll position
      if original_win and vim.api.nvim_win_is_valid(original_win) and original_view then
        vim.api.nvim_set_current_win(original_win)
        vim.fn.winrestview(original_view)
      end
      current_win = nil
      current_buf = nil
      original_win = nil
      original_view = nil
    end
    vim.keymap.set("n", "<Esc>", close_float, { buffer = current_buf })
    vim.keymap.set("n", "q", close_float, { buffer = current_buf })
  end
  
  -- Clear old highlights and apply new ones
  vim.api.nvim_buf_clear_namespace(current_buf, -1, 0, -1)
  
  local diag_hl = "DiagnosticFloatingError"
  if severity == "WARN" then diag_hl = "DiagnosticFloatingWarn"
  elseif severity == "INFO" then diag_hl = "DiagnosticFloatingInfo"
  elseif severity == "HINT" then diag_hl = "DiagnosticFloatingHint"
  end
  
  for i = 0, diagnostic_end_line - 1 do
    vim.api.nvim_buf_add_highlight(current_buf, -1, diag_hl, i, 0, -1)
  end
  for i = diagnostic_end_line, #lines - 1 do
    vim.api.nvim_buf_add_highlight(current_buf, -1, "AIDiagnosticText", i, 0, -1)
  end
end

-- Call Claude API
local function call_claude(prompt, callback)
  local api_key = get_api_key()
  if not api_key then
    callback("Error: No ANTHROPIC_API_KEY found in ~/.env")
    return
  end
  
  local json_body = vim.fn.json_encode({
    model = "claude-3-5-haiku-latest",
    max_tokens = 300,
    messages = {
      { role = "user", content = prompt }
    }
  })
  
  -- Write body to temp file to avoid shell escaping issues
  local tmp = os.tmpname()
  local f = io.open(tmp, "w")
  f:write(json_body)
  f:close()
  
  local cmd = string.format(
    'curl -s https://api.anthropic.com/v1/messages ' ..
    '-H "Content-Type: application/json" ' ..
    '-H "x-api-key: %s" ' ..
    '-H "anthropic-version: 2023-06-01" ' ..
    '-d @%s',
    api_key, tmp
  )
  
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      os.remove(tmp)
      if data and data[1] then
        local response = table.concat(data, "")
        local ok, decoded = pcall(vim.fn.json_decode, response)
        if ok and decoded.content and decoded.content[1] then
          callback(decoded.content[1].text)
        else
          callback("Error parsing response: " .. response:sub(1, 200))
        end
      end
    end,
    on_stderr = function(_, data)
      if data and data[1] and data[1] ~= "" then
        callback("Error: " .. table.concat(data, ""))
      end
    end,
  })
end

-- Main function: show AI-enhanced diagnostic
function M.explain_diagnostic()
  -- Save original window and view before opening float
  original_win = vim.api.nvim_get_current_win()
  original_view = vim.fn.winsaveview()
  
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
  if #diagnostics == 0 then
    vim.notify("No diagnostics on this line", vim.log.levels.INFO)
    return
  end
  
  local diag = diagnostics[1]
  local context = get_context(bufnr, line)
  local filetype = vim.bo[bufnr].filetype
  
  -- Show diagnostic immediately with loading indicator
  local severity = ({ "ERROR", "WARN", "INFO", "HINT" })[diag.severity] or "DIAGNOSTIC"
  local initial_text = string.format("%s: %s\n\nAsking Claude...", severity, diag.message)
  show_float(initial_text, severity, false)
  
  local actual_line_num = line + 1  -- Convert to 1-indexed
  
  local prompt = string.format(
    "You're a helpful coding assistant that appears in a small tooltip. " ..
    "Briefly explain this %s diagnostic error and suggest what the developer should change in 2-3 sentences, " ..
    "then suggest a fix in 1-2 sentences.\n\n" ..
    "Diagnostic on line %d: %s\n\n" ..
    "Code context:\n```%s\n%s\n```",
    filetype, actual_line_num, diag.message, filetype, context
  )
  
  call_claude(prompt, function(response)
    vim.schedule(function()
      -- Update the existing window with full content
      local full_text = string.format("%s: %s\n\n%s", severity, diag.message, response)
      show_float(full_text, severity, true)
    end)
  end)
end

return M
