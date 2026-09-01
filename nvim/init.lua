local buffers = require("buffers")
local filewatch = require("filewatch")
require("hooks")
require("python")
require("rust")
require("markdown")
require("neotree")

-- Basic Settings

vim.opt.termguicolors = true
vim.opt.number = true              -- Show line numbers
--vim.opt.relativenumber = true      -- Relative line numbers
vim.opt.ignorecase = true          -- Ignore case in search
vim.opt.smartcase = true           -- Unless search has capitals
vim.opt.hlsearch = false           -- Don't highlight searches
vim.opt.wrap = false               -- Don't wrap lines
vim.opt.tabstop = 4                -- Tab width
vim.opt.shiftwidth = 4             -- Indent width
vim.opt.expandtab = true           -- Use spaces instead of tabs
vim.opt.fillchars:append({ diff = ' ' })  -- Use space instead of hyphens in diff
vim.g.mapleader = ' '              -- Space as leader key

-- Buffer/scroll position settings
vim.opt.hidden = true              -- Keep buffers loaded in background
vim.opt.laststatus = 0             -- Disable bottom statusline (using winbar instead)
vim.opt.scrolloff = 0              -- Disabled for smoother edge scrolling
vim.opt.smoothscroll = true        -- Smooth scrolling at edges
vim.opt.cursorline = true          -- Highlight current line
vim.opt.colorcolumn = "80,110"     -- Column guides
vim.opt.list = true                -- Show whitespace
vim.opt.listchars = { space = '·', tab = '→ ', trail = '·' }
vim.opt.autoread = true            -- Auto-reload files when changed externally
vim.opt.whichwrap:append("<,>,h,l,[,]")  -- Wrap cursor to next/prev line

-- Click on inactive window focuses without viewport jumping
vim.keymap.set('n', '<LeftMouse>', buffers.handle_mouse_click)

-- Key Mappings
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = 'Toggle file browser' })
vim.keymap.set('n', '<leader>w', '<C-w>', { desc = 'Window commands' })

-- Window/Split management
vim.keymap.set('n', '<leader>t', function()
  if vim.bo.filetype == 'neo-tree' then
    vim.cmd('wincmd p')
  end
  vim.cmd('rightbelow vsplit')
  vim.api.nvim_set_current_buf(buffers.get_or_create_empty())
end, { desc = 'New split right' })

vim.keymap.set('n', '<leader>T', function()
  if vim.bo.filetype == 'neo-tree' then
    vim.cmd('wincmd p')
  end
  vim.cmd('leftabove vsplit')
  vim.api.nvim_set_current_buf(buffers.get_or_create_empty())
end, { desc = 'New split left' })

vim.keymap.set('n', '<leader>n', function()
  vim.api.nvim_set_current_buf(buffers.get_or_create_empty())
end, { desc = 'New/empty buffer' })

-- Buffer navigation (cycles through tabs at top)
vim.keymap.set('n', '<leader>]', ':BufferLineCycleNext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>[', ':BufferLineCyclePrev<CR>', { desc = 'Previous buffer' })

-- Navigate wrapped lines by screen line, so j/k step through a soft-wrapped
-- paragraph instead of jumping the whole logical line. A count still means
-- real lines (5j is five lines, not five screen rows), and with 'nowrap' gj/gk
-- are identical to j/k, so this is inert in code buffers. Deliberately not
-- mapped in operator-pending mode: gj is not linewise, which would change what
-- dj and yj do.
vim.keymap.set({ 'n', 'v' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = 'Down by screen line' })
vim.keymap.set({ 'n', 'v' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = 'Up by screen line' })

-- Keep selection after indent
vim.keymap.set('v', '>', '>gv', { silent = true })
vim.keymap.set('v', '<', '<gv', { silent = true })

vim.keymap.set('n', '<leader>x', function()
  local current = vim.fn.bufnr()
  vim.cmd('BufferLineCyclePrev')
  vim.cmd('bdelete ' .. current)
end, { desc = 'Close buffer' })

vim.keymap.set('n', '<leader>X', function()
  local current = vim.fn.bufnr()
  vim.cmd('BufferLineCyclePrev')
  vim.cmd('bdelete! ' .. current)
end, { desc = 'Force close buffer' })

-- :wc = write and close buffer (keeps window open)
vim.api.nvim_create_user_command('Wc', function()
  local current = vim.fn.bufnr()
  vim.cmd('write')
  vim.cmd('BufferLineCyclePrev')
  vim.cmd('bdelete ' .. current)
end, {})
vim.cmd('cnoreabbrev wc Wc')

-- Telescope (fuzzy finder)
local launch_cwd = vim.fn.getcwd()
vim.keymap.set('n', '<leader>ff', function()
  require('telescope.builtin').find_files({ cwd = launch_cwd })
end, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', function()
  require('telescope.builtin').live_grep({ cwd = launch_cwd })
end, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', { desc = 'Browse buffers' })

-- Git
vim.keymap.set('n', '<leader>d', ':DiffviewOpen<CR>', { desc = 'Git diff view' })

-- Git diff viewer
-- :D              - unstaged changes (working tree diff)
-- :D main...head  - diff branch against main (PR review)
-- :D head~3       - last 3 commits
-- :Dq             - close the diff view
vim.api.nvim_create_user_command('D', function(opts)
  local args = opts.args:gsub('%f[%w]head%f[%W]', 'HEAD')
  vim.cmd('DiffviewOpen ' .. args)
end, { nargs = '?' })

vim.api.nvim_create_user_command('Dq', function()
  vim.cmd('DiffviewClose')
end, {})

-- Diffview only watches .git/index itself (and that is disabled below), so the
-- working tree comes from filewatch like everything else.
filewatch.subscribe(launch_cwd, function()
  local ok, lib = pcall(require, 'diffview.lib')
  -- get_current_view() is already scoped to the focused tabpage
  if ok and lib.get_current_view() then
    pcall(vim.cmd, 'DiffviewRefresh')
  end
end)

-- Diagnostics
vim.keymap.set('n', '<leader>v', function()
  require('ai_diagnostics').explain_diagnostic()
end, { desc = 'AI explain diagnostic' })

-- LSP
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'gr', function()
  require('telescope.builtin').lsp_references()
end, { desc = 'Find references' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover docs' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })


-- Auto-reload files changed outside Neovim.
-- checktime is still what performs the reload -- it honours 'autoread' and the
-- modified flag, works out which buffers are stale, and fires
-- FileChangedShellPost below. Watchman only decides *when* to call it, so it no
-- longer runs on idle. winsaveview/winrestview stay because reloading moves the
-- viewport.
filewatch.subscribe(launch_cwd, function()
  local view = vim.fn.winsaveview()
  vim.cmd('checktime')
  vim.fn.winrestview(view)
end)

-- Refresh illuminate after file reloads
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function()
    vim.defer_fn(function()
      pcall(function()
        local illuminate = require("illuminate")
        illuminate.invisible_buf()
        illuminate.visible_buf()
      end)
    end, 50)
  end,
})

-- Format JSON files on open
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.json",
  callback = function()
    vim.opt_local.wrap = true
    -- Check if jq can parse the file first
    local filepath = vim.fn.expand("%:p")
    local check = vim.fn.system("jq empty " .. vim.fn.shellescape(filepath) .. " 2>&1")
    if vim.v.shell_error == 0 then
      vim.cmd("%!jq .")
    end
  end,
})

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load colorscheme before plugins so colors are available
vim.cmd.colorscheme('slomp')

-- Plugin Setup
require("lazy").setup({

  -- Status line (at top of each window)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = _G.slomp_colors.lualine,
        },
        sections = {}, -- disable bottom
        inactive_sections = {},  -- hide bottom container
        winbar = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff' },
          lualine_c = { 'filename' },
          lualine_x = { 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        inactive_winbar = {
          lualine_c = { 'filename' },
          lualine_x = { 'filetype' },
        },
      })
    end,
  },

  -- File browser
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = false,
        open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
        window = {
          position = "right",
          width = 30,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
        },
        filesystem = {
          follow_current_file = {
            enabled = true,
          },
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
          },
        },
      })
    end,
  },

  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "python", "javascript", "typescript", "json", "yaml", "rust" },
        sync_install = true,  -- Block until parsers are installed (helps on fresh machines)
        auto_install = true,
        highlight = {
          enable = true,
        },
      })
    end,
  },

  -- Buffer tabs at the top
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          separator_style = "thin",
          always_show_bufferline = true,
          offsets = {
            { filetype = "neo-tree", text = "Files", highlight = "Directory", separator = true },
          },
        },
      })
    end,
  },


  -- Claude code MCP integration
  {
    "coder/claudecode.nvim",
    config = function()
      -- Neuter the closeAllDiffTabs MCP tool. MUST run before setup(), which
      -- starts the websocket server and registers tools by copying
      -- tool_module.handler -- patch after that and the original is already in
      -- the registry.
      --
      -- Claude calls this tool after you accept a diff it opened itself, to
      -- clean up. Its handler closes EVERY window with 'diff' set, without
      -- checking whether it opened them, so it also closes diffview's two panes
      -- and leaves only the file panel. It fires on message submit -- so
      -- selecting a line inside `:D` and sending it to Claude destroys the diff
      -- you were discussing.
      --
      -- Left registered rather than removed so the call still gets a valid
      -- response instead of a JSON-RPC "Tool not found" error.
      local ok, tool = pcall(require, "claudecode.tools.close_all_diff_tabs")
      if ok then
        tool.handler = function()
          return { content = { { type = "text", text = "Closed 0 diff tabs (disabled locally)" } } }
        end
      end

      require("claudecode").setup({
        -- Claude runs in a tmux pane, so nvim should never manage a terminal.
        terminal = { provider = "none" },
      })
    end,
  },

  -- Agent Code MCP integration (local dev)
  -- {
  --   dir = "~/Work/agentcode.nvim",
  --   name = "agentcode.nvim",
  --   config = function()
  --     require("claudecode").setup({})
  --   end,
  -- },
  --
  -- OpenCode integration
  -- {
  --   "sudo-tee/opencode.nvim",
  --   config = function()
  --     require("opencode").setup({
  --       default_global_keymaps = false,
  --     })
  --   end,
  -- },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
    end,
  },

  -- MDX: no treesitter grammar exists for MDX, so this sets the filetype and
  -- injects markdown for prose + tsx for the embedded JSX.
  -- No setup() to call: the plugin is just ftdetect + treesitter injection
  -- queries under after/.
  {
    "davidmh/mdx.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  -- Markdown rendering in-editor
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("render-markdown").setup({
        code = { disable = {} },
      })
    end,
  },

  -- LSP server configs (provides definitions for vim.lsp.enable)
  { "neovim/nvim-lspconfig" },

  -- Git diff viewer
  {
    -- Local fork (github.com/tcdent/diffview.nvim, branch preserve-fold-state):
    -- upstream rebuilds the file tree on every refresh, which discards the
    -- panel's collapsed directories. Not yet submitted upstream.
    dir = "~/Work/diffview.nvim",
    name = "diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("diffview").setup({
        -- filewatch drives refreshes; diffview's own fs_poll on .git/index
        -- would be a second watcher doing the same job.
        watch_index = false,
      })
    end,
  },

  -- Highlight word under cursor
  {
    "RRethy/vim-illuminate",
    config = function()
      require("illuminate").configure({
        delay = 500,
        under_cursor = true,
      })
    end,
  },
})
