vim.opt.background = 'light'

vim.cmd 'hi clear'
if vim.fn.exists 'syntax_on' then
  vim.cmd 'syntax reset'
end

vim.g.colors_name = 'night_owl_light'

vim.g.night_owl_light_italic = vim.g.night_owl_light_italic or 1
vim.g.night_owl_light_bold = vim.g.night_owl_light_bold or 0

-- Converted highlight commands to pure Lua:
vim.api.nvim_set_hl(0, 'ColorColumn', { bg = '#F0F0F0' })
vim.api.nvim_set_hl(0, 'Cursor', { fg = '#90A7B2' })
vim.api.nvim_set_hl(0, 'CursorIM', { fg = '#90A7B2' })
vim.api.nvim_set_hl(0, 'CursorColumn', { bg = '#F0F0F0' })
vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#F0F0F0' })
vim.api.nvim_set_hl(0, 'CursorLineNr', { bg = '#F0F0F0' })
vim.api.nvim_set_hl(0, 'Directory', { fg = '#403f53', bg = '#FBFBFB' })
vim.api.nvim_set_hl(0, 'LineNr', { fg = '#90A7B2', bg = '#FBFBFB' })
vim.api.nvim_set_hl(0, 'Normal', { fg = '#403f53', bg = '#FBFBFB' })
vim.api.nvim_set_hl(0, 'Comment', { fg = '#939dbb', italic = (vim.g.night_owl_light_italic == 1) })
vim.api.nvim_set_hl(0, 'Constant', { fg = '#4876d6' })
vim.api.nvim_set_hl(0, 'Number', { fg = '#aa0982' })
vim.api.nvim_set_hl(0, 'Boolean', { fg = '#bc5454' })

if vim.fn.exists '*term_setansicolors' then
  vim.g.terminal_ansi_colors = {
    '#403F53',
    '#288ED7',
    '#2AA298',
    '#08916A',
    '#D6438A',
    '#DE3D3B',
    '#F0F0F0',
    '#E0AF02',
    '#403F53',
    '#FF0000',
    '#00FF00',
    '#DE3D3B',
    '#0000FF',
    '#FF0000',
    '#0000FF',
    '#FFFFFF',
    '#FFFFFF',
    '#403F53',
  }
end

if vim.fn.has 'nvim' then
  vim.g.terminal_color_color_0 = '#403f53'
  vim.g.terminal_color_color_1 = '#288ed7'
  vim.g.terminal_color_color_2 = '#2AA298'
  vim.g.terminal_color_color_3 = '#08916a'
  vim.g.terminal_color_color_4 = '#d6438a'
  vim.g.terminal_color_color_5 = '#de3d3b'
  vim.g.terminal_color_color_6 = '#F0F0F0'
  vim.g.terminal_color_color_7 = '#E0AF02'
  vim.g.terminal_color_color_8 = '#403f53'
  vim.g.terminal_color_color_9 = '#FF0000'
  vim.g.terminal_color_color_10 = '#00FF00'
  vim.g.terminal_color_color_11 = '#de3d3b'
  vim.g.terminal_color_color_12 = '#0000FF'
  vim.g.terminal_color_color_13 = '#FF0000'
  vim.g.terminal_color_color_14 = '#0000FF'
  vim.g.terminal_color_color_15 = '#FFFFFF'
  vim.g.terminal_color_foreground = '#FFFFFF'
  vim.g.terminal_color_background = '#403f53'
end

print 'Night Owl Light colorscheme loaded'
