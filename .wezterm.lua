-- vim:tw=100:ts=2:sw=2:ai:et:ff=unix:fenc=utf-8:et:fixeol:eol:fdm=marker:fdl=0:fen:fmr=<<(,)>>:
--
-- WezTerm configuration file.



-- IMPORTS, VARIABLES AND OTHER CONFIG SETTINGS


local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux


-- Fonts I frequently use. <<(
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
    -- Ligature test:
    --  ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
    --  ~ < > = + _ _ ( ) * & ^ % $ # @ ! { } [ ] \ | / ? : ; , . ` ' " ´ ` ˜
    --  => -> <> <= >= != !== === ~= |> <- --> || .- :- .= {..} 1/2 3/8 100/48
    --  a b c d e f g h i j k l m n o p q r s t u v x w y z
    --  A B C D E F G H I J K L M N O P Q R S T U V X W Y Z
    harfbuzz_features = {
      -- Minimal: default style (ss01); no ligatures in `=` (ss19); raised bar `f` (ss20); dashed
      -- zero (zero); highlight some weird glyphs (cv99).
      'ss01', 'ss19', 'ss20', 'zero', 'cv99',

      -- Different: closed construction (ss02); no ligatures in `=` (ss19); raised bar `f` (ss20);
      -- dashed zero (zero); different `g`, `j`, `Q`, `8`, `5` (respectively); highlight some weird
      -- glyphs (cv99).
      -- 'ss02', 'ss19', 'ss20', 'zero', 'cv03', 'cv04', 'cv16', 'cv19', 'cv20', 'cv99',
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
-- )>>


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


wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
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


-- TODO: get this to work one day?
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


local function color_schemes_by_name(opts)
  setmetatable(opts, {
    __index = {
      -- Defaults to darker colors.
      min_light = 0.0,
      max_light = 0.4
    }
  })

  local schemes = wezterm.color.get_builtin_schemes()
  local chosen_schemes = {}
  for name, scheme in pairs(schemes) do
    if scheme.background then
      -- parse into a color object
      local bg = wezterm.color.parse(scheme.background)
      -- and extract HSLA information
      local h, s, l, a = bg:hsla()

      -- `l` is the "lightness" of the color where 0 is darkest
      -- and 1 is lightest.
      if (opts.min_light <= l) and (l <= opts.max_light) then
        table.insert(chosen_schemes, name)
      end
    end
  end

  table.sort(chosen_schemes)
  return chosen_schemes
end


local color_schemes_to_pick = color_schemes_by_name{
  min_light = 0, 
  max_light = 0.2
}


-- Fill this as I find schemes that I like. Later I can randomize only them.
local color_scheme_override = {
  -- Use `false` to select a random color scheme or the index of the favorite to use as override.
  override = false,
  favorites = {
    'Dracula',                                -- Lua is 1-based, so this has index 1.
    'Dark Pastel',                            -- 2
    'CrayonPonyFish',                         -- 3
    'Heetch Dark (base16)',                   -- 4
    'Canvased Pastel (terminal.sexy)',        -- 5
    'Synth Midnight Terminal Light (base16)', -- 6
    'midnight-in-mojave',                     -- 7
    'Slate (Gogh)',                           -- 8
    'tlh (terminal.sexy)',                    -- 9
    'Man Page (Gogh)',                        -- 10
    'Builtin Solarized Dark',                 -- 11
    'Apathy (base16)',                        -- 12
    'gooey (Gogh)',                           -- 13
    'SynthwaveAlpha (Gogh)',                  -- 14
    'Liquid Carbon Transparent (Gogh)',       -- 15
    'Afterglow (Gogh)',                       -- 16
  }
}


function get_scheme(opts)
  local scheme = 'Dracula' 

  if not opts.force_random and color_scheme_override.override then
    scheme = color_scheme_override.favorites[color_scheme_override.override]
    print('Overriden scheme: ' .. scheme)
  else
    scheme = color_schemes_to_pick[math.random(#color_schemes_to_pick)]
    print('Random scheme: ' .. scheme)
  end

  return scheme
end


wezterm.on('window-config-reloaded', function(window, pane)
  if not window:get_config_overrides() then
    window:set_config_overrides({
      color_scheme = get_scheme{force_random = false}
    })
  end
end)


-- next event


-- MAIN SETTINGS


config.window_background_opacity = 1
config.text_background_opacity = 1
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

config.colors = {
  cursor_bg = 'orange',
  cursor_fg = 'black',
}

config.default_gui_startup_args = { 'start', SCRATCH_SCRIPT }

local should_blink = false
if should_blink then
  config.default_cursor_style = 'BlinkingUnderline'
  config.cursor_thickness = '0.1pt'
  config.cursor_blink_rate = 500
else
  config.default_cursor_style = 'SteadyUnderline'
end



-- KEYBINDINGS


function change_color_scheme(window, pane)
  wezterm.gui.gui_windows()[1]:set_config_overrides{ color_scheme = get_scheme{force_random = true} }
end


config.keys = {
  { key = 'h', mods = 'SHIFT|CTRL', action = wezterm.action.Search { Regex = 'hello' } },
  { key = 'j', mods = 'ALT|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = 'k', mods = 'ALT|SHIFT', action = act.ActivateTabRelative(1) },
  { key = 't', mods = 'SHIFT|ALT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 't', mods = 'SHIFT|CTRL', action = wezterm.action_callback(change_color_scheme) },
}



-- RETURN THE CONFIG OBJECT, TO APPLY ALL SETTINGS


return config

