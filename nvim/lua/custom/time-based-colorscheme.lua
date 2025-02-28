--[[

    Adjust your colorscheme based on the time of the day (light: day, dark: night),
    with an override for when it is necessary (e.g. a very bright room at night).

--]]

local hour_now = tonumber(os.date '%H')
local daylight_ends = 19
local daylight_starts = 6

local time_based = 'time_based' -- The colorscheme will be chosen based on time of the day.
local dark = 'dark' -- Override with a dark mode of your choice.
local light = 'light' -- Override with a light mode of your choice.

-- Chose your mode here.
vim.g.colorscheme_mode = time_based
vim.g.colorscheme_mode_dark = 'tokyonight-night'
vim.g.colorscheme_mode_light = 'tokyonight-day'

local define_colorscheme = function()
  local ambient_is_dark = hour_now < daylight_starts or hour_now >= daylight_ends
  if vim.g.colorscheme_mode == dark or ambient_is_dark then
    return vim.g.colorscheme_mode_dark
  elseif vim.g.colorscheme_mode == light or not ambient_is_dark then
    return vim.g.colorscheme_mode_light
  else
    return vim.g.colorscheme_mode_dark
  end
end

return {
  define_colorscheme = define_colorscheme,
}
