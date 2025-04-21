--
-- This module provides a way to set the colorscheme based on the time of day.
--
local time_based = "time_based"
local dark = "dark" -- Override with a dark mode of your choice.
local light = "light" -- Override with a light mode of your choice.

math.randomseed(os.time())

-- When choosing light or dark mode randomly, use these options.
local dark_mode_options = {
  -- -- These are nice, but with at least one weird color.
  -- 'sorbet',  -- telescope thingy is weird grey
  -- 'zaibatsu',  -- telescope thingy is weird light grey
  -- 'vim',  -- accent color is bright pink that hurt my eyes (and I like pink)
  -- 'goodwolf',  -- very few colors...
  -- --

  "habamax", -- a bit dead, but still nice
  "badwolf", -- classic and still good!
  "retrobox", -- interesting... badwolf vibes
  "vividchalk", -- really vivid!
  "wildcharm", -- kind of vivid too, though less than vividchalk
  "tokyonight-night", -- so good!
  "tokyonight-storm", -- so good too!
  "tokyonight-moon", -- so good three!
  "catppuccin-frappe",
  "catppuccin-macchiato",
  "catppuccin-mocha",
}
local light_mode_options = {
  "tokyonight-day",
  "catppuccin-latte",
}
vim.g.colorscheme_mode_dark = dark_mode_options[math.random(#dark_mode_options)]
vim.g.colorscheme_mode_light = light_mode_options[math.random(#light_mode_options)]

vim.g.colorscheme_modes = { time_based, dark, light }
vim.g.colorscheme_mode = vim.g.colorscheme_modes[1]

local is_dark = function()
  local hour_now = tonumber(os.date("%H"))
  local daylight_ends = 17
  local daylight_starts = 5

  return hour_now < daylight_starts or hour_now >= daylight_ends
end

local get = function(new_mode)
  new_mode = new_mode or vim.g.colorscheme_mode or time_based
  if new_mode == dark or is_dark() then
    return vim.g.colorscheme_mode_dark
  elseif new_mode == light or not is_dark() then
    return vim.g.colorscheme_mode_light
  else
    return vim.g.colorscheme_mode_dark
  end
end

local transparent_background = function()
  -- vim.cmd 'hi Normal guibg=NONE ctermbg=NONE'
end

local set = function(mode)
  return function()
    vim.cmd.colorscheme(get(mode))
    transparent_background()
  end
end

return {
  get = get,
  set = set,
  is_dark = is_dark,
  is_light = function()
    return not is_dark()
  end,
}
