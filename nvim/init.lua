-- Minimal Neovim Configuration
-- Simple setup with file browser, syntax highlighting, and tabs

-- Basic Settings
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
vim.opt.scrolloff = 20             -- Keep lines visible above/below cursor
vim.opt.cursorline = true          -- Highlight current line
vim.opt.colorcolumn = "80,110"     -- Column guides
vim.opt.list = true                -- Show whitespace
vim.opt.listchars = { space = '·', tab = '→ ', trail = '·' }

-- Click on inactive window focuses without viewport jumping
vim.keymap.set('n', '<LeftMouse>', function()
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
end)

-- Key Mappings
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = 'Toggle file browser' })
vim.keymap.set('n', '<leader>w', '<C-w>', { desc = 'Window commands' })

-- Window/Split management
vim.keymap.set('n', '<leader>t', function()
  if vim.bo.filetype == 'neo-tree' then
    vim.cmd('wincmd p')  -- go to previous window
  end
  -- Find existing empty unnamed buffer
  local empty_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf)
      and vim.api.nvim_buf_get_name(buf) == ''
      and vim.bo[buf].buftype == ''
      and vim.api.nvim_buf_line_count(buf) == 1
      and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == '' then
      empty_buf = buf
      break
    end
  end
  if empty_buf then
    vim.cmd('rightbelow vsplit')
    vim.api.nvim_set_current_buf(empty_buf)
  else
    vim.cmd('rightbelow vnew')
  end
end, { desc = 'New vertical split' })

-- Buffer navigation (cycles through tabs at top)
vim.keymap.set('n', '<leader>]', ':BufferLineCycleNext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>[', ':BufferLineCyclePrev<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>x', ':bdelete<CR>', { desc = 'Close buffer' })

-- Telescope (fuzzy finder)
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', { desc = 'Browse buffers' })

-- Git
vim.keymap.set('n', '<leader>d', ':DiffviewOpen<CR>', { desc = 'Git diff view' })
vim.keymap.set('n', '<leader>D', ':DiffviewClose<CR>', { desc = 'Close diff view' })

-- Diagnostics
vim.keymap.set('n', '<leader>l', vim.diagnostic.open_float, { desc = 'Show diagnostic' })


-- Auto-reload files changed outside Neovim
vim.opt.autoread = true            -- Auto-reload files when changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  callback = function()
    vim.cmd("checktime")
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

-- Plugin Setup
require("lazy").setup({

  -- Status line (at top of each window)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local custom_theme = {
        normal = {
          a = { fg = '#1E1E1E', bg = '#c86ead', gui = 'bold' },
          b = { fg = '#D4D4D4', bg = '#2c2c2c' },
          c = { fg = '#D4D4D4', bg = '#1E1E1E' },
          z = { fg = '#1E1E1E', bg = '#c86ead' },
        },
        insert = {
          a = { fg = '#1E1E1E', bg = '#bd9a6e', gui = 'bold' },
          z = { fg = '#1E1E1E', bg = '#bd9a6e' },
        },
        visual = {
          a = { fg = '#1E1E1E', bg = '#6CAFBD', gui = 'bold' },
          z = { fg = '#1E1E1E', bg = '#6CAFBD' },
        },
        replace = {
          a = { fg = '#1E1E1E', bg = '#D65A77', gui = 'bold' },
          z = { fg = '#1E1E1E', bg = '#D65A77' },
        },
        inactive = {
          a = { fg = '#808080', bg = '#1E1E1E' },
          b = { fg = '#808080', bg = '#1E1E1E' },
          c = { fg = '#808080', bg = '#1E1E1E' },
        },
      }
      require("lualine").setup({
        options = {
          theme = custom_theme,
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
        ensure_installed = { "lua", "vim", "python", "javascript", "typescript", "json", "yaml" },
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

  -- Claude Code MCP integration (WebSocket server like VS Code)
  {
    "coder/claudecode.nvim",
    config = function()
      require("claudecode").setup({})
    end,
  },

  -- GitHub Copilot
  {
    "github/copilot.vim",
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
    end,
  },

  -- Markdown rendering in-editor
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    config = function()
      require("render-markdown").setup({})
      -- Reapply colorscheme so our highlights take precedence
      vim.cmd.colorscheme('slomp')
    end,
  },

  -- LSP server configs (provides definitions for vim.lsp.enable)
  { "neovim/nvim-lspconfig" },

  -- Git diff viewer
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("diffview").setup({})
    end,
  },
})

-- Load SLOMP colorscheme (after plugins so our highlights take precedence)
vim.cmd.colorscheme('slomp')

-- Prevent horizontal scrolling in neo-tree
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

-- Markdown settings (wrap for prose)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true  -- wrap at word boundaries
  end,
})

-- LSP setup (Neovim 0.11+ native)
vim.lsp.config('pyright', {
  settings = {
    python = {
      venvPath = ".",
      venv = ".venv",
    },
  },
})
vim.lsp.enable('pyright')

-- LSP keybindings (only active when LSP attaches)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  end,
})

-- Load language-specific configs
require("config.hooks")
