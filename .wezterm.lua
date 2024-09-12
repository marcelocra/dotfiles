-- vim:tw=100:ts=2:sw=2:ai:et:ff=unix:fenc=utf-8:et:fixeol:eol:fdm=marker:fdl=0:fen:
--
-- WezTerm configuration file.



-- IMPORTS, VARIABLES AND OTHER CONFIG SETTINGS


local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

-- Fonts I frequently use.
local fonts = {
  meslo = wezterm.font({
    family = 'MesloLGS NF',
    harfbuzz_features = {},
  }),

  meslo_bold = wezterm.font({
    family = 'MesloLGS NF',
    harfbuzz_features = {},
    weight = 'Bold',
  }),

  jb = wezterm.font({
    family = 'JetBrains Mono',
    harfbuzz_features = {
      'ss02', 'ss19', 'ss20', 'zero', 'cv03', 'cv04', 'cv16', 'cv19', 'cv20', 'cv99'
    },
  }),

  cascadia = wezterm.font({
    family = 'Cascadia Code NF',
    harfbuzz_features = {
      'ss01', 'ss19', 'ss20', 'calt=0',
    },
  }),

  fira = wezterm.font({
    family = 'Fira Code',
    harfbuzz_features = {
      'calt=0', 'cv01', 'cv02', 'cv05', 'cv09', 'ss05', 'ss03', 'cv16', 'cv30', 'cv25', 'cv26',
      'cv32', 'cv28', 'ss10', 'cv14', 'cv12',
    },
  }),
}

local config = wezterm.config_builder()

local SCRATCH_SCRIPT = '/home/marcelocra/projects/dotfiles/.rc.scratch'



-- EVENTS


wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  if window then
    local active_screen = wezterm.gui.screens().active
    local screen_width =  active_screen.width
    local screen_height = active_screen.height
    local panel_width = 47  -- This is configured in Cinnamon directly.

    local start_x = (screen_width + panel_width) / 2
    local start_y = 0
    local window_width = (screen_width - panel_width) / 2
    local window_height = screen_height

    local gui_window = window:gui_window()
    gui_window:set_position(start_x, start_y)
    gui_window:set_inner_size(window_width, screen_height)
  end
end)



wezterm.on( 'format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  -- The filled in variant of the < symbol
  local solid_left_arrow = wezterm.nerdfonts.pl_right_hard_divider

  -- The filled in variant of the > symbol
  local solid_right_arrow = wezterm.nerdfonts.pl_left_hard_divider

  -- This function returns the suggested title for a tab.
  -- It prefers the title that was set via `tab:set_title()`
  -- or `wezterm cli set-tab-title`, but falls back to the
  -- title of the active pane in that tab.
  function tab_title(tab_info)
    local title = tab_info.tab_title
    -- if the tab title is explicitly set, take that
    if title and #title > 0 then
      return title
    end
    -- Otherwise, use the title from the active pane
    -- in that tab
    return tab_info.active_pane.title
  end

  local edge_background = '#0b0022'
  local background = '#1b1032'
  local foreground = '#808080'

  if tab.is_active then
    background = '#2b2042'
    foreground = '#c0c0c0'
  elseif hover then
    background = '#3b3052'
    foreground = '#909090'
  end

  local edge_foreground = background

  local title = tab_title(tab)

  -- ensure that the titles fit in the available space,
  -- and that we have room for the edges.
  title = wezterm.truncate_right(title, max_width - 2)

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = solid_left_arrow },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = solid_right_arrow },
  }
end)

-- wezterm.on('window-focus-changed', function(window, pane)
--   if window:is_focused() then
--     act.SpawnCommandInNewWindow {
--       args = { SCRATCH_SCRIPT, 'disconnect' }
--     }
--   else
--     act.SpawnCommandInNewWindow {
--       args = { SCRATCH_SCRIPT, 'connect' }
--     }
--   end
-- end)



-- MAIN SETTINGS


config.window_background_opacity = 0.92
config.window_decorations = 'RESIZE'

config.font = fonts.jb
config.font_size = 10

config.scrollback_lines = 5000

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

config.color_scheme = 'Dracula'

config.default_gui_startup_args = { 'start', SCRATCH_SCRIPT }

config.default_cursor_style = 'BlinkingUnderline'
config.cursor_thickness = '0.1pt'
config.cursor_blink_rate = 500



-- KEYBINDINGS


config.keys = {
  {
    key = 'h',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.Search { Regex = 'hello' },
  },
  { key = 'j', mods = 'ALT|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = 'k', mods = 'ALT|SHIFT', action = act.ActivateTabRelative(1) },
  {
    key = 't',
    mods = 'SHIFT|ALT',
    action = act.SpawnTab 'CurrentPaneDomain',
  }
}



-- RETURN THE CONFIG OBJECT, TO APPLY ALL SETTINGS


return config

