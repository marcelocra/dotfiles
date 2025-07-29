--[[

    Adjust your colorscheme based on the time of the day (light: day, dark: night),
    with an override for when it is necessary (e.g. a very bright room at night).

--]]

local hour_now = tonumber(os.date '%H')
local daylight_ends = 18
local daylight_starts = 6

local dark = 'dark' -- Override with a dark mode of your choice.
local light = 'light' -- Override with a light mode of your choice.

-- Enable modern terminal features before setting the colorscheme.
-- require 'custom.modern-terminal-support'

local define_colorscheme = function(new_mode)
  new_mode = new_mode or vim.g.colorscheme_mode
  local ambient_is_dark = hour_now < daylight_starts or hour_now >= daylight_ends
  if new_mode == dark or ambient_is_dark then
    return vim.g.colorscheme_mode_dark
  elseif new_mode == light or not ambient_is_dark then
    return vim.g.colorscheme_mode_light
  else
    return vim.g.colorscheme_mode_dark
  end
end

return {
  define_colorscheme = define_colorscheme,
}
