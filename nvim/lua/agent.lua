-- Integration points for an agent driving this editor over the nvim socket.
--
-- Call these from a shell with:
--   nvim --server /tmp/nvim-<session>.sock --remote-expr "v:lua.agent.focus('x.lua', 34, 34, 68)"
--
-- `v:lua.<global>.<fn>(...)` is evaluated directly by --remote-expr, so there is
-- no luaeval() wrapper, no nested quote escaping and no staging scripts in /tmp.
-- Every function returns a description of what it did, so the caller never needs
-- a second round trip to confirm it worked.
--
-- Conventions worth keeping:
--   * relative paths resolve against the GLOBAL cwd, never vim.fn.getcwd(),
--     which returns the window-local directory when one is set
--   * :edit silently creates an empty buffer for a path that does not exist, so
--     every path is checked with filereadable() first
--   * annotations are extmarks in named namespaces; they never touch buffer
--     text, so nothing can be accidentally written to disk

local M = {}

local NS_RANGE = vim.api.nvim_create_namespace("agent_range")
local NS_NOTE = vim.api.nvim_create_namespace("agent_note")

---------------------------------------------------------------------------
-- helpers
---------------------------------------------------------------------------

---Resolve a path against the global cwd and verify it exists.
---@return string? abs, string? err
local function resolve(path)
  if not path or path == "" then
    return nil, "no path given"
  end
  local abs = path
  if not abs:match("^[/~]") then
    abs = vim.fs.joinpath(vim.fn.getcwd(-1, -1), abs)
  end
  abs = vim.fn.fnamemodify(vim.fn.expand(abs), ":p"):gsub("/$", "")
  if vim.fn.filereadable(abs) == 0 then
    return nil, "not readable: " .. abs
  end
  return abs, nil
end

---A window suitable for editing: not neo-tree, not a panel, not a terminal.
local function editable_win()
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local b = vim.api.nvim_win_get_buf(w)
    if vim.bo[b].buftype == "" and vim.bo[b].filetype ~= "neo-tree" then
      return w
    end
  end
end

---@return string? reason
local function dirty_guard()
  local names = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].modified then
      names[#names + 1] = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ":t")
    end
  end
  if #names > 0 then
    return "refused: unsaved changes in " .. table.concat(names, ", ")
  end
end

local function highlight(buf, first, last)
  local n = vim.api.nvim_buf_line_count(buf)
  for l = math.max(first, 1) - 1, math.min(last, n) - 1 do
    vim.api.nvim_buf_set_extmark(buf, NS_RANGE, l, 0, { line_hl_group = "Visual" })
  end
end

---@return integer buf, integer lines, integer landed  -- landed may be clamped
local function open_in(win, abs, line)
  vim.api.nvim_set_current_win(win)
  vim.cmd("edit " .. vim.fn.fnameescape(abs))
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(buf, NS_RANGE, 0, -1)
  local n = vim.api.nvim_buf_line_count(buf)
  local landed = math.min(math.max(line or 1, 1), n)
  vim.api.nvim_win_set_cursor(win, { landed, 0 })
  vim.cmd("normal! zz")
  return buf, n, landed
end

---"path", "path:12", "path:12:20-40"
local function parse_spec(spec)
  local path, line, first, last = spec:match("^(.-):(%d+):(%d+)%-(%d+)$")
  if path then
    return path, tonumber(line), tonumber(first), tonumber(last)
  end
  path, line = spec:match("^(.-):(%d+)$")
  if path then
    return path, tonumber(line)
  end
  return spec, 1
end

---------------------------------------------------------------------------
-- showing things
---------------------------------------------------------------------------

---Open a file, put the cursor on `line`, and optionally highlight first..last.
---The highlight is an extmark, not a visual selection: the buffer is unchanged
---and the editor stays in normal mode.
function M.focus(path, line, first, last)
  local abs, err = resolve(path)
  if not abs then
    return err
  end
  local win = editable_win()
  if not win then
    return "refused: no editable window"
  end
  local buf, n, landed = open_in(win, abs, line)
  if first then
    highlight(buf, first, last or first)
  end
  -- Report where the cursor actually landed, not what was asked for: a line
  -- past EOF is clamped, and the return value is the caller's only confirmation.
  local clamped = (line and landed ~= line) and string.format(" (clamped from %d)", line) or ""
  return string.format("%s:%d%s%s (%d lines, win %d)", vim.fn.fnamemodify(abs, ":."),
    landed, first and string.format(" hl %d-%d", first, last or first) or "", clamped, n, win)
end

---Lay files out in vertical columns, left to right, and focus the last one.
---Specs are "path", "path:line" or "path:line:first-last".
---
---The file tree is left open and its width restored afterwards. An earlier
---version closed it, ran :only, and reopened it -- but `Neotree show` is
---asynchronous, and its deferred callback would try to focus a window :only had
---already destroyed, raising "Invalid window id" INSIDE a scheduled callback.
---That surfaces as a `Press ENTER` prompt, which blocks every subsequent socket
---call and cannot be caught by pcall here. Closing individual windows instead
---avoids the race entirely.
function M.columns(...)
  local specs = { ... }
  if #specs == 0 then
    return "refused: no specs"
  end
  local guard = dirty_guard()
  if guard then
    return guard
  end

  local plan = {}
  for i, spec in ipairs(specs) do
    local path, line, first, last = parse_spec(spec)
    local abs, err = resolve(path)
    if not abs then
      -- A spec that fails to parse falls through as a path, so a trailing
      -- ":12:20" looks like a missing file. Say what the format is instead.
      if path:match(":%d") then
        err = err .. "  (expected path, path:line or path:line:first-last)"
      end
      return string.format("refused (spec %d): %s", i, err)
    end
    plan[#plan + 1] = { abs = abs, line = line, first = first, last = last }
  end

  -- Remember the tree so its width can be restored after `wincmd =`.
  local tree_win, tree_width
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "neo-tree" then
      tree_win, tree_width = w, vim.api.nvim_win_get_width(w)
    end
  end

  local keep = editable_win()
  if not keep then
    return "refused: no editable window"
  end
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if w ~= keep and w ~= tree_win then
      pcall(vim.api.nvim_win_close, w, false)
    end
  end
  vim.api.nvim_set_current_win(keep)

  local out = {}
  for i, p in ipairs(plan) do
    if i > 1 then
      vim.cmd("rightbelow vsplit")
    end
    local w = vim.api.nvim_get_current_win()
    local buf = open_in(w, p.abs, p.line)
    if p.first then
      highlight(buf, p.first, p.last or p.first)
    end
    out[#out + 1] = { win = w, name = vim.fn.fnamemodify(p.abs, ":t") }
  end
  vim.cmd("wincmd =")
  if tree_win and vim.api.nvim_win_is_valid(tree_win) then
    pcall(vim.api.nvim_win_set_width, tree_win, tree_width)
  end
  local focus = out[#out].win
  vim.api.nvim_set_current_win(focus)

  local desc = {}
  for i, o in ipairs(out) do
    desc[i] = string.format("%s(w%d)", o.name, vim.api.nvim_win_get_width(o.win))
  end
  return "columns: " .. table.concat(desc, " | ") .. " focus=" .. out[#out].name
end

---------------------------------------------------------------------------
-- annotating
---------------------------------------------------------------------------

---Short note at the end of a line. Use for a remark that fits on one line.
function M.note(path, line, text)
  local abs, err = resolve(path)
  if not abs then
    return err
  end
  local buf = vim.fn.bufadd(abs)
  vim.fn.bufload(buf)
  vim.api.nvim_buf_set_extmark(buf, NS_NOTE, math.max(line - 1, 0), 0, {
    virt_text = { { "  " .. text, "DiagnosticVirtualTextInfo" } },
    virt_text_pos = "eol",
  })
  return string.format("note on %s:%d", vim.fn.fnamemodify(abs, ":."), line)
end

---Multi-line note rendered below a line, like a review comment. `text` may be a
---string with newlines or a list of lines.
function M.note_block(path, line, text)
  local abs, err = resolve(path)
  if not abs then
    return err
  end
  local lines = type(text) == "table" and text or vim.split(tostring(text), "\n", { plain = true })
  local virt = {}
  for _, t in ipairs(lines) do
    virt[#virt + 1] = { { "   | " .. t, "Comment" } }
  end
  local buf = vim.fn.bufadd(abs)
  vim.fn.bufload(buf)
  vim.api.nvim_buf_set_extmark(buf, NS_NOTE, math.max(line - 1, 0), 0, { virt_lines = virt })
  return string.format("note_block on %s:%d (%d lines)", vim.fn.fnamemodify(abs, ":."), line, #lines)
end

---Remove every highlight and note this module has placed, in all buffers.
function M.clear()
  local n = 0
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then
      for _, ns in ipairs({ NS_RANGE, NS_NOTE }) do
        n = n + #vim.api.nvim_buf_get_extmarks(b, ns, 0, -1, {})
        vim.api.nvim_buf_clear_namespace(b, ns, 0, -1)
      end
    end
  end
  return string.format("cleared %d marks", n)
end

---------------------------------------------------------------------------
-- diffs
---------------------------------------------------------------------------

---Open the diff view. `rev` takes the same arguments as :D ("", "main...HEAD").
---Diffview opens its own tabpage, so the existing layout is left alone.
function M.diff(rev)
  local ok, e = pcall(vim.cmd, "DiffviewOpen " .. (rev or ""))
  if not ok then
    return "refused: " .. tostring(e)
  end
  return "diff opened (tab " .. vim.fn.tabpagenr() .. ")"
end

---Show one file inside the open diff view, by its repo-relative path.
function M.diff_file(path)
  local ok, lib = pcall(require, "diffview.lib")
  local view = ok and lib.get_current_view()
  if not view then
    return "refused: no diff view open"
  end
  for _, set in ipairs({ "working", "staged" }) do
    for _, f in ipairs(view.files[set] or {}) do
      if f.path == path then
        view:set_file(f, true, true)
        return string.format("showing %s (%s, %s)", f.path, f.status, set)
      end
    end
  end
  return "not in the change set: " .. path
end

---Files in the open diff view, so the caller can pick one without guessing.
---`only_modified` drops untracked entries, which usually swamp the list.
function M.diff_files(only_modified)
  local ok, lib = pcall(require, "diffview.lib")
  local view = ok and lib.get_current_view()
  if not view then
    return "refused: no diff view open"
  end
  local out = {}
  for _, set in ipairs({ "working", "staged" }) do
    for _, f in ipairs(view.files[set] or {}) do
      if not (only_modified and f.status == "?") then
        out[#out + 1] = string.format("%s %s", f.status, f.path)
      end
    end
  end
  return #out == 0 and "no files" or table.concat(out, "\n")
end

---------------------------------------------------------------------------
-- reading back
---------------------------------------------------------------------------

---What is on screen: current file, cursor, any visual selection, and -- for a
---diff buffer -- which side of the diff it is, which line numbers alone cannot
---tell you.
function M.where()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local pos = vim.api.nvim_win_get_cursor(0)
  local side = "file"
  if name:match("^diffview://") then
    side = name:match("/%.git/") and "diff:index-or-HEAD" or "diff:panel"
  elseif vim.wo.diff then
    side = "diff:working-tree"
  end
  local out = {
    string.format("%s [%s]", name ~= "" and vim.fn.fnamemodify(name, ":.") or "[No Name]", side),
    string.format("cursor=%d:%d of %d lines", pos[1], pos[2] + 1, vim.api.nvim_buf_line_count(buf)),
  }
  local m = vim.fn.mode()
  if m:match("^[vV\22]") then
    local s, e = vim.fn.line("v"), vim.fn.line(".")
    if s > e then
      s, e = e, s
    end
    out[#out + 1] = string.format("selection=%d-%d", s, e)
  end
  out[#out + 1] = "context:"
  local from = math.max(pos[1] - 3, 1)
  for i, l in ipairs(vim.api.nvim_buf_get_lines(buf, from - 1, pos[1] + 2, false)) do
    out[#out + 1] = string.format("%s%5d %s", (from + i - 1) == pos[1] and ">" or " ", from + i - 1, l)
  end
  return table.concat(out, "\n")
end

---Editor state worth knowing before driving it: cwd in both scopes (they can
---differ), unsaved buffers, windows, and whether filewatch is connected.
function M.status()
  local out = {
    string.format("cwd global=%s window=%s", vim.fn.getcwd(-1, -1), vim.fn.getcwd()),
  }
  local guard = dirty_guard()
  out[#out + 1] = guard and ("UNSAVED " .. guard:gsub("^refused: ", "")) or "all buffers saved"
  local wins = {}
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local b = vim.api.nvim_win_get_buf(w)
    wins[#wins + 1] = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ":t")
  end
  out[#out + 1] = string.format("tab %d/%d: %s", vim.fn.tabpagenr(),
    #vim.api.nvim_list_tabpages(), table.concat(wins, " | "))
  local ok, fw = pcall(require, "filewatch")
  if ok then
    local n = 0
    for _ in pairs(fw.status()) do
      n = n + 1
    end
    out[#out + 1] = string.format("filewatch: %d subscriptions", n)
  end
  return table.concat(out, "\n")
end

_G.agent = M
return M
