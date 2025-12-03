-- SLOMP Theme for Neovim
-- Ported from VSCode settings.json

vim.cmd('hi clear')
if vim.fn.exists('syntax_on') then
  vim.cmd('syntax reset')
end

vim.g.colors_name = 'slomp'
vim.o.background = 'dark'

-- Helper function to set highlights
local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- UI Colors
hi('Normal', { fg = '#dd7a9f', bg = '#1E1E1E' })
hi('NormalFloat', { bg = '#1E1E1E' })
hi('CursorLine', { bg = '#1a1a1a' })
hi('CursorLineNr', { fg = '#c86ead', bg = '#1a1a1a' })
hi('LineNr', { fg = '#6774AF' })
hi('SignColumn', { bg = '#1E1E1E' })
hi('VertSplit', { fg = '#a86e9a' })
hi('StatusLine', { fg = '#dd7a9f', bg = '#2c2c2c' })
hi('StatusLineNC', { fg = '#6774AF', bg = '#1a1a1a' })

-- Selection
hi('Visual', { bg = '#135564' })
hi('VisualNOS', { bg = '#135564' })

-- Search
hi('Search', { fg = '#1E1E1E', bg = '#ca9bbc' })
hi('IncSearch', { fg = '#1E1E1E', bg = '#c86ead' })

-- Cursor
hi('Cursor', { fg = '#1E1E1E', bg = '#c86ead' })

-- Diff (for Claude Code and git diffs)
hi('DiffAdd', { bg = '#1a3a2a' })              -- Added lines (subtle green)
hi('DiffChange', { bg = '#2a2a1a' })           -- Changed lines (subtle yellow)
hi('DiffDelete', { fg = '#5a3a3a', bg = '#2a1a1a' })  -- Deleted lines (subtle red)
hi('DiffText', { bg = '#3a3a2a' })             -- Changed text within line

-- Syntax Highlighting
hi('Comment', { fg = '#6774AF', italic = true })
hi('Constant', { fg = '#df9acb' })
hi('String', { fg = '#b78b67' })
hi('Number', { fg = '#9eb882' })
hi('Boolean', { fg = '#df9acb' })

hi('Identifier', { fg = '#cb768a' })
hi('Function', { fg = '#df9acb' })

hi('Statement', { fg = '#90618e' })
hi('Keyword', { fg = '#90618e' })
hi('Conditional', { fg = '#90618e' })
hi('Repeat', { fg = '#90618e' })
hi('Label', { fg = '#90618e' })
hi('Operator', { fg = '#dd7a9f' })

hi('Type', { fg = '#bd9a6e' })
hi('Structure', { fg = '#bd9a6e' })
hi('StorageClass', { fg = '#90618e' })

hi('Special', { fg = '#ca9bbc' })
hi('SpecialChar', { fg = '#ca9bbc' })
hi('Delimiter', { fg = '#dd7a9f' })

hi('Error', { fg = '#b78b67' })
hi('Warning', { fg = '#564b42' })
hi('Info', { fg = '#6774AF' })

-- Treesitter
hi('@variable', { fg = '#cb768a' })
hi('@variable.builtin', { fg = '#b783c9' })
hi('@variable.parameter', { fg = '#64a0ac' })
hi('@variable.member', { fg = '#cb768a' })

hi('@function', { fg = '#df9acb' })
hi('@function.call', { fg = '#ca9bbc' })
hi('@function.builtin', { fg = '#df9acb' })

hi('@keyword', { fg = '#90618e' })
hi('@keyword.function', { fg = '#90618e' })
hi('@keyword.return', { fg = '#90618e' })

hi('@type', { fg = '#bd9a6e' })
hi('@type.builtin', { fg = '#bd9a6e' })
hi('@type.definition', { fg = '#6CAFBD' })

hi('@string', { fg = '#b78b67' })
hi('@string.documentation', { fg = '#6774AF', italic = true })

hi('@comment', { fg = '#6774AF', italic = true })

hi('@constant', { fg = '#df9acb' })
hi('@constant.builtin', { fg = '#df9acb' })
hi('@number', { fg = '#9eb882' })
hi('@boolean', { fg = '#df9acb' })

hi('@operator', { fg = '#dd7a9f' })
hi('@punctuation.bracket', { fg = '#dd7a9f' })
hi('@punctuation.delimiter', { fg = '#dd7a9f' })

hi('@constructor', { fg = '#6CAFBD' })
hi('@attribute', { fg = '#5f5db4' })
hi('@namespace', { fg = '#6CAFBD' })

-- Python specific
hi('@variable.builtin.python', { fg = '#6273c0' }) -- self, cls
hi('@decorator.python', { fg = '#5f5db4' })
hi('@class.python', { fg = '#6CAFBD' })

-- Neo-tree
hi('NeoTreeNormal', { fg = '#dd7a9f', bg = '#1E1E1E' })
hi('NeoTreeNormalNC', { fg = '#dd7a9f', bg = '#1E1E1E' })
hi('NeoTreeVertSplit', { fg = '#a86e9a', bg = '#1E1E1E' })
hi('NeoTreeWinSeparator', { fg = '#a86e9a', bg = '#1E1E1E' })
hi('NeoTreeDirectoryName', { fg = '#bd9a6e' })
hi('NeoTreeDirectoryIcon', { fg = '#bd9a6e' })
hi('NeoTreeFileName', { fg = '#dd7a9f' })
hi('NeoTreeFileIcon', { fg = '#ca9bbc' })
hi('NeoTreeGitModified', { fg = '#bd9a6e' })
hi('NeoTreeGitUntracked', { fg = '#D65A77' })

-- Lualine
hi('LualineNormal', { fg = '#dd7a9f', bg = '#2c2c2c' })
hi('LualineInsert', { fg = '#1E1E1E', bg = '#bd9a6e' })
hi('LualineVisual', { fg = '#1E1E1E', bg = '#c86ead' })
hi('LualineReplace', { fg = '#1E1E1E', bg = '#D65A77' })

-- Render-markdown (code blocks)
hi('RenderMarkdownCode', { bg = '#252525' })
hi('RenderMarkdownCodeInline', { bg = '#252525' })

-- Render-markdown headings (no background)
hi('RenderMarkdownH1Bg', { bg = 'NONE' })
hi('RenderMarkdownH2Bg', { bg = 'NONE' })
hi('RenderMarkdownH3Bg', { bg = 'NONE' })
hi('RenderMarkdownH4Bg', { bg = 'NONE' })
hi('RenderMarkdownH5Bg', { bg = 'NONE' })
hi('RenderMarkdownH6Bg', { bg = 'NONE' })

-- Markdown text (use white for prose)
hi('@markup', { fg = '#D4D4D4' })
hi('@markup.raw', { fg = '#D4D4D4', bg = '#252525' })
-- hi('@text', { fg = '#D4D4D4' })
-- hi('@spell', { fg = '#D4D4D4' })
hi('@spell.markdown', { fg = '#D4D4D4' })

-- Terminal colors
vim.g.terminal_color_0 = '#1E1E1E'  -- black
vim.g.terminal_color_1 = '#D65A77'  -- red
vim.g.terminal_color_2 = '#bd9a6e'  -- green
vim.g.terminal_color_3 = '#ca9bbc'  -- yellow
vim.g.terminal_color_4 = '#6774AF'  -- blue
vim.g.terminal_color_5 = '#c86ead'  -- magenta
vim.g.terminal_color_6 = '#6CAFBD'  -- cyan
vim.g.terminal_color_7 = '#dd7a9f'  -- white

vim.g.terminal_color_8 = '#2c2c2c'   -- bright black
vim.g.terminal_color_9 = '#D65A77'   -- bright red
vim.g.terminal_color_10 = '#bd9a6e'  -- bright green
vim.g.terminal_color_11 = '#bd9a6e'  -- bright yellow
vim.g.terminal_color_12 = '#a41e6a'  -- bright blue
vim.g.terminal_color_13 = '#c86ead'  -- bright magenta
vim.g.terminal_color_14 = '#6CAFBD'  -- bright cyan
vim.g.terminal_color_15 = '#dd7a9f'  -- bright white
