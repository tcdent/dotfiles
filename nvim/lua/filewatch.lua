-- File change events for the whole config, backed by watchman.
--
-- Watchman is the single source of truth. It already owns watch deduplication
-- (`watch-project` reuses a watch higher in the tree), coalescing (the settle
-- period), VCS noise filtering (`ignore_vcs`, plus deferral while
-- .git/index.lock exists), per-subscription filtering (`expression`) and resync
-- after a daemon restart (`is_fresh_instance`). None of that is reimplemented
-- here -- this module only carries its event stream into Lua callbacks.
--
-- Each subscription is a |sockconnect()| channel to watchman's unix socket.
-- Watchman parses one command per read, and a subscription only ever sends two
-- (`watch-project`, then `subscribe`) before it goes read-only -- so a channel
-- per subscription satisfies that by construction and needs no send queue.
-- Watches are still shared: watchman dedups them per root no matter how many
-- clients connect.
--
-- Watches outlive nvim, and that is intentional: closing a project leaves its
-- root warm so the next session reattaches instantly. Watchman reaps a root
-- once it has been idle with no subscriptions for `idle_reap_age_seconds`
-- (default 5 days), so nothing is unwatched on exit. `watchman watch-list`
-- shows what is live.
--
-- There is no fallback: a missing or dead daemon is a misconfigured system, and
-- is reported as an error.
--
-- Install: brew install watchman   (see ../../README.md)

local M = {}

local subs = {} -- name -> { chan, prefix }
local next_id = 0
local sockname

-- Watchman has no .gitignore support and nothing here cares about build or
-- vendor output, so those trees are excluded once rather than per subscriber.
-- Without it a cargo build wakes every consumer thousands of times: quiche has
-- 18907 files under its watch, 2266 of them outside target/. Only unambiguous
-- output dirs belong here -- a wrong entry silently hides real edits.
--
-- `.git` is the important one. `ignore_vcs` stops watchman tracking its
-- *contents*, but watchman stores its query cookies in there, so the directory
-- entry itself still reports as changed whenever anything runs git. That closes
-- a loop: an event refreshes the diff view, the refresh shells out to git, git
-- touches .git, which fires the next event.
local IGNORED_DIRS = {
  '.git',
  '.hg',
  '.svn',
  'target',
  'node_modules',
  '__pycache__',
  '.venv',
  'venv',
  '.mypy_cache',
  '.pytest_cache',
  '.ruff_cache',
}

local function filtered(expression)
  local ignored = { 'anyof' }
  for _, dir in ipairs(IGNORED_DIRS) do
    -- the directory entry itself (basename match, any depth) and its contents
    ignored[#ignored + 1] = { 'name', dir }
    ignored[#ignored + 1] = { 'dirname', dir }
  end
  local expr = { 'not', ignored }
  return expression and { 'allof', expr, expression } or expr
end

-- Nvim closes the channels on exit; that is not a misconfiguration.
local function err(msg)
  if vim.v.exiting ~= vim.NIL then
    return
  end
  vim.notify('filewatch: ' .. msg, vim.log.levels.ERROR)
end

-- `get-sockname` doubles as the daemon's start trigger, so it is the one place
-- the CLI is used. Concurrent callers may each ask once; they agree on the
-- answer and the process is short-lived.
local function resolve(cb)
  if sockname then
    return cb(sockname)
  end
  vim.system({ 'watchman', 'get-sockname' }, { text = true }, function(res)
    vim.schedule(function()
      local ok, info = pcall(vim.json.decode, res.stdout)
      if res.code ~= 0 or not ok or not info.sockname then
        return err('cannot reach watchman: ' .. vim.trim(res.stderr or res.stdout or ''))
      end
      sockname = info.sockname
      cb(sockname)
    end)
  end)
end

--- Subscribe to changes under `root`.
--- @param root string directory to watch
--- @param on_change fun(paths: string[], fresh: boolean) absolute paths that
---   changed; `fresh` means watchman resynced and callers should refresh fully.
--- @param expression table? watchman expression, e.g. { 'suffix', 'py' }.
---   Filtering happens in the daemon; without it every change is delivered.
--- @return fun() unsubscribe
function M.subscribe(root, on_change, expression)
  if vim.fn.executable('watchman') == 0 then
    err('watchman is not installed -- run: brew install watchman')
    return function() end
  end

  root = vim.fs.normalize(vim.fn.fnamemodify(root, ':p')):gsub('/$', '')
  next_id = next_id + 1
  local name = 'nvim-filewatch-' .. next_id
  local entry = {}
  subs[name] = entry

  resolve(function(path)
    local chan
    -- Only one command is ever outstanding here, so the reply handler is a
    -- single slot rather than a queue.
    local awaiting
    local tail = ''

    local function line(msg)
      if msg.error then
        return err(msg.error)
      end
      if msg.subscription then
        local paths = {}
        for _, file in ipairs(msg.files or {}) do
          paths[#paths + 1] = entry.prefix .. '/' .. file
        end
        return on_change(paths, msg.is_fresh_instance == true)
      end
      local cb = awaiting
      awaiting = nil
      if cb then
        cb(msg)
      end
    end

    local ok, res = pcall(vim.fn.sockconnect, 'pipe', path, {
      on_data = function(_, data)
        -- |channel-lines|: the first and last items may be partial lines.
        data[1] = tail .. data[1]
        tail = table.remove(data)
        for _, text in ipairs(data) do
          local decoded, msg = pcall(vim.json.decode, text)
          if decoded then
            line(msg)
          end
        end
      end,
    })
    if not ok then
      return err('cannot connect to ' .. path .. ': ' .. tostring(res))
    end
    chan = res
    entry.chan = chan

    -- The channel can close underneath a pending reply -- nvim exiting, or an
    -- unsubscribe racing the watch-project response -- and chansend throws on a
    -- closed stream.
    local function send(cmd)
      pcall(vim.fn.chansend, chan, vim.json.encode(cmd) .. '\n')
    end

    awaiting = function(msg)
      if not msg.watch then
        return err('watch-project failed for ' .. root)
      end
      entry.prefix = msg.relative_path and (msg.watch .. '/' .. msg.relative_path) or msg.watch
      send({
        'subscribe',
        msg.watch,
        name,
        {
          fields = { 'name' },
          empty_on_fresh_instance = true,
          relative_root = msg.relative_path,
          expression = filtered(expression),
        },
      })
    end

    send({ 'watch-project', root })
  end)

  -- Closing the channel ends the subscription; no unsubscribe command needed.
  return function()
    local s = subs[name]
    subs[name] = nil
    if s and s.chan then
      pcall(vim.fn.chanclose, s.chan)
    end
  end
end

--- Active subscriptions, for debugging.
function M.status()
  local out = {}
  for name, s in pairs(subs) do
    out[name] = { root = s.prefix, channel = s.chan }
  end
  return out
end

return M
