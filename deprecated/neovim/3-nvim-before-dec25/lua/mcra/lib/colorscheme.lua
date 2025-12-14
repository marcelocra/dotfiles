--
-- This module provides a way to set the colorscheme based on the time of day.
--
local time_based = "time_based"
local dark = "dark" -- Override with a dark mode of your choice.
local light = "light" -- Override with a light mode of your choice.

-- Defaults.
vim.g.use_random_theme = true
vim.g.use_transparent_background = false

vim.g.colorscheme_mode_dark = "tokyonight-night"
vim.g.colorscheme_mode_light = "catppuccin-latte"
vim.g.current_colorscheme = nil

local set_random_theme = function()
  math.randomseed(os.time())

  -- When choosing light or dark mode randomly, use these options.
  local dark_mode_options = {
    -- -- These are nice, but with at least one weird color.
    -- -- EDIT: Perhaps it was because of the problem I had with tmux. Now I'm
    -- tryign to use nvim only.
    "sorbet", -- telescope thingy is weird grey
    "zaibatsu", -- telescope thingy is weird light grey
    "vim", -- accent color is bright pink that hurt my eyes (and I like pink)
    "goodwolf", -- very few colors...
    --

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
    "solarized",
  }
  local light_mode_options = {
    "tokyonight-day",
    "catppuccin-latte",
    "lunaperche",
    "default",
    "delek",
    "morning",
    "solarized",
    "retrobox",
  }
  vim.g.colorscheme_mode_dark = dark_mode_options[math.random(#dark_mode_options)]
  vim.g.colorscheme_mode_light = light_mode_options[math.random(#light_mode_options)]
end

vim.g.colorscheme_modes = { time_based, dark, light }
vim.g.colorscheme_mode = vim.g.colorscheme_modes[1]

--- Returns true if the current time is in the dark period, false otherwise.
--- @return boolean
local is_dark = function()
  local hour_now = tonumber(os.date("%H"))
  local daylight_ends = 17
  local daylight_starts = 5

  return hour_now < daylight_starts or hour_now >= daylight_ends
end

local transparent_background = function()
  if not vim.g.use_transparent_background then
    return
  end

  vim.cmd("hi Normal guibg=none ctermbg=none")
  vim.cmd("hi NonText guibg=none ctermbg=none")
end

local randomize_theme = function()
  if vim.g.use_random_theme then
    set_random_theme()
  end
end

local setup = function()
  randomize_theme()
  transparent_background()
end

local set_colorscheme = function(old_colorscheme, new_mode)
  local new_colorscheme
  if new_mode == dark then
    vim.g.colorscheme_mode = dark
    vim.opt.background = "dark"
    new_colorscheme = vim.g.colorscheme_mode_dark
  else
    vim.g.colorscheme_mode = light
    vim.opt.background = "light"
    new_colorscheme = vim.g.colorscheme_mode_light
  end

  setup()

  if old_colorscheme then
    print("Changing from " .. old_colorscheme .. " to " .. new_colorscheme)
  else
    print("Setting colorscheme to " .. new_colorscheme)
  end

  vim.g.current_colorscheme = new_colorscheme
  require("mcra.lib.modern-term-support").setup()
  vim.cmd.colorscheme(new_colorscheme)
end

local set_dark = function(curr)
  set_colorscheme(curr, dark)
end

local set_light = function(curr)
  set_colorscheme(curr, light)
end

--- Changes the colorscheme.
--- @param mode 'time_based'|'light'|'dark'|nil The mode to use for determining the colorscheme.
--- @return function
local set = function(mode)
  local new_mode = mode or vim.g.colorscheme_mode

  -- New modes must be checked for light or dark first, so that it is possible
  -- to override time-based modes.

  if new_mode == dark then
    return set_dark
  end

  if new_mode == light then
    return set_light
  end

  -- At this point we know that the mode is time_based.

  if is_dark() then
    return set_dark
  end

  return set_light
end

--- Toggles through the available colorscheme modes.
--- @return nil
local toggle = function()
  local current_mode = vim.g.colorscheme_mode
  local new_mode

  if (current_mode == time_based and is_dark()) or (current_mode == dark) then
    new_mode = light
  else
    new_mode = dark
  end

  set(new_mode)(vim.g.current_colorscheme)
end

return {
  set = set,
  toggle = toggle,
  is_dark = is_dark,
  is_light = function()
    return not is_dark()
  end,

  -- Used at lua/mcra/plugins/colorschemes.lua
  default = "gruvbox",
}
