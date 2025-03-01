-- vim:tw=100:ts=2:sw=2:ai:et:ff=unix:fenc=utf-8:et:fixeol:eol:fdm=marker:fdl=0:fen:fmr=<<(,)>>:
--
-- WezTerm configuration file.

-- IMPORTS, VARIABLES AND OTHER CONFIG SETTINGS

local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

-- Fonts I frequently use.

-- Options: 'Fixed', 'Fixed Extended', 'Extended'.
local which_iosevka = "Iosevka Fixed Extended"

local good_font_size = 11
local fonts = {
  meslo = {
    font = wezterm.font({
      -- family = 'MesloLGL Nerd Font', -- more space between lines
      family = "MesloLGM Nerd Font", -- medium space between lines
      -- family = "MesloLGS Nerd Font", -- less space between lines
      harfbuzz_features = {
        -- "cv10 10",
      },
      weight = 400,
    }),
    size = good_font_size,
  },

  jb = {
    font = wezterm.font({
      family = "JetBrains Mono",
      weight = 400,
      -- Ligature test:
      --  ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
      --  ~ < > = + _ _ ( ) * & ^ % $ # @ ! { } [ ] \ | / ? : ; , . ` ' " ´ ` ˜
      --  => -> <> <= >= != !== === ~= |> <- --> || .- :- .= {..} 1/2 3/8 100/48
      --  a b c d e f g h i j k l m n o p q r s t u v x w y z
      --  A B C D E F G H I J K L M N O P Q R S T U V X W Y Z
      harfbuzz_features = {
        -- Minimal: default style (ss01); no ligatures in `=` (ss19); raised bar `f` (ss20); dashed
        -- zero (zero); highlight some weird glyphs (cv99).
        -- 'ss01', 'ss19', 'ss20', 'zero', 'cv99',

        -- Different: closed construction (ss02); no ligatures in `=` (ss19); raised bar `f` (ss20);
        -- dashed zero (zero); different `g`, `j`, `Q`, `8`, `5` (respectively); highlight some weird
        -- glyphs (cv99).
        -- 'ss02', 'ss19', 'ss20', 'zero', 'cv03', 'cv04', 'cv16', 'cv19', 'cv20', 'cv99',
      },
    }),
    size = 10,
  },

  jb_nf = {
    font = wezterm.font({
      family = "JetBrainsMono Nerd Font",
      weight = 400,
      -- Ligature test:
      --  ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
      --  ~ < > = + _ _ ( ) * & ^ % $ # @ ! { } [ ] \ | / ? : ; , . ` ' " ´ ` ˜
      --  => -> <> <= >= != !== === ~= |> <- --> || .- :- .= {..} 1/2 3/8 100/48
      --  a b c d e f g h i j k l m n o p q r s t u v x w y z
      --  A B C D E F G H I J K L M N O P Q R S T U V X W Y Z
      harfbuzz_features = {
        -- 'zero'
        -- 'ss01', 'ss19', 'ss20', 'zero', 'cv99',
        "ss02",
        "ss19",
        "ss20",
        "zero",
        "cv03",
        "cv04",
        "cv16",
        "cv18",
        "cv19",
        "cv20",
        "cv99",
      },
    }),
    size = 11,
  },

  cascadia = {
    font = wezterm.font({
      -- family = 'Cascadia Code NF',
      family = "CaskaydiaCove NF",
      weight = 400,
      harfbuzz_features = {
        "calt 0",
        "ss01",
        "ss19",
        "ss20",
      },
    }),
    size = good_font_size,
  },

  fira = {
    font = wezterm.font({
      family = "Fira Code",
      harfbuzz_features = {
        "calt 0",
        "cv01",
        "cv02",
        "cv05",
        "cv09",
        "ss05",
        "ss03",
        "cv16",
        "cv30",
        "cv25",
        "cv26",
        "cv32",
        "cv28",
        "ss10",
        "cv14",
        "cv12",
      },
    }),
    size = good_font_size,
  },

  geist = { font = wezterm.font({
    family = "Geist Mono",
  }), size = good_font_size },

  noto = {
    font = wezterm.font({
      family = "Noto Sans Mono",
      weight = 400,
    }),
    size = 11,
    line_height = 0.9,
  },

  dm = {
    font = wezterm.font({
      family = "DM Mono",
      weight = 700,
      harfbuzz_features = {
        "ss01", -- rounded commas
        "ss03", -- non curvy 'g'
        "ss04", -- non curvy '6' and '9'
      },
    }),
    size = good_font_size,
  },

  scp = {
    font = wezterm.font({
      family = "SourceCodeVF",
      -- weight = 700,
      harfbuzz_features = {
        "cv17",
        "cv01",
        "cv02",
        "zero",
      },
    }),
    size = good_font_size,
  },

  iosevka = {
    font = wezterm.font({
      family = which_iosevka,
      weight = 400,
      harfbuzz_features = {
        -- Font alternatives. <<(
        -- ss01: Andale Mono
        -- ss02: Anonymous Pro
        -- ss03: Consolas
        -- ss04: Menlo
        -- ss05: Fira Mono
        -- ss06: Liberation Mono
        -- ss07: Monaco
        -- ss08: Pragmata Pro
        -- ss09: Source Code Pro
        -- ss10: Envy Code R
        -- ss11: X Window
        -- ss12: Ubuntu Mono
        -- ss13: Lucida
        -- ss14: JetBrains Mono
        -- ss15: IBM Plex Mono
        -- ss16: PT Mono
        -- ss17: Recursive Mono
        -- ss18: Input Mono
        -- ss20: Curly
        -- )>>

        -- Others:
        -- Lucida Console with some changes.
        -- 'ss13', 'cv02 4', 'cv04 11', 'cv05 8', 'cv10 10',
        -- 'ss13', 'cv02 1', 'cv04 3', 'cv05 4', 'cv10 25',
      },
    }),
    size = good_font_size,
  },

  iosevka_jb = {
    font = wezterm.font({
      family = which_iosevka,
      weight = 400,
      harfbuzz_features = {
        "ss14",
      },
    }),
    size = good_font_size,
  },

  iosevka_lucida = {
    font = wezterm.font({
      family = which_iosevka,
      weight = 400,
      harfbuzz_features = {
        "ss13",
        "cv10 7",
        -- Variations.
        -- 'ss13', 'cv02 4', 'cv04 11', 'cv05 8', 'cv10 10',
        -- 'ss13', 'cv02 1', 'cv04 3', 'cv05 4', 'cv10 25',
      },
    }),
    size = good_font_size,
  },

  iosevka_menlo = {
    font = wezterm.font({
      family = which_iosevka,
      weight = 400,
      harfbuzz_features = {
        "ss04",
      },
    }),
    size = 15,
  },

  iosevka_monaco = {
    font = wezterm.font({
      family = which_iosevka,
      weight = 400,
      harfbuzz_features = {
        "ss07",
      },
    }),
    size = 15,
  },

  victor_mono = {
    font = wezterm.font({
      family = "Victor Mono",
      weight = 600,
      harfbuzz_features = {
        -- 'calt=0', -- no ligatures (particularly for `==` and `!=`)
        -- 'ss01', -- different 'a'
        "ss02", -- different dashed zero (up to ss05)
        "ss06", -- crossed '7'
        "ss07", -- different '6' and  '9'
        "ss08", -- more fish-like stuff (::<)
        -- |> >- <-> <| <> |- .- :: -.- -> => == === != !== ::<
      },
    }),
    size = good_font_size,
  },

  code_new_roman = {
    font = wezterm.font({
      family = "CodeNewRoman Nerd Font",
      weight = 400,
    }),

    size = good_font_size,
  },

  recursive = {
    font = wezterm.font({
      family = "RecMonoLinear Nerd Font",
      weight = 400,
    }),
    size = good_font_size,
  },

  recursive_alt = {
    font = wezterm.font({
      family = "RecMonoDuotone Nerd Font",
      weight = 400,
    }),
    size = good_font_size,
  },

  hack = { font = wezterm.font({
    family = "Hack Nerd Font",
    weight = 400,
  }), size = good_font_size },

  blex = { font = wezterm.font({
    family = "Blex Mono Nerd Font",
    weight = 400,
  }), size = good_font_size },

  commit = {
    font = wezterm.font({
      family = "CommitMono Nerd Font",
      weight = 400,
    }),
    size = good_font_size,
  },
}

local config = wezterm.config_builder()

local SCRATCH_SCRIPT = os.getenv("HOME") .. "/projects/dotfiles/.rc.scratch"

-- EVENTS

wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  if window then
    local active_screen = wezterm.gui.screens().active
    local screen_width = active_screen.width
    local screen_height = active_screen.height
    local panel_width = 47 -- This is configured in Cinnamon directly.

    local start_x = (screen_width + panel_width) / 2
    local start_y = 0
    local window_width = (screen_width - panel_width) / 2
    local window_height = screen_height

    local gui_window = window:gui_window()
    gui_window:set_position(start_x, start_y)
    gui_window:set_inner_size(window_width, screen_height)
  end
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
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

  local edge_background = "#0b0022"
  local background = "#1b1032"
  local foreground = "#808080"

  if tab.is_active then
    background = "#2b2042"
    foreground = "#c0c0c0"
  elseif hover then
    background = "#3b3052"
    foreground = "#909090"
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

-- Implementation that leverages your existing .rc.scratch script
-- local focus_loss_timer = nil
-- local focus_loss_detach_minutes = 10
-- local focus_loss_detach_seconds = 3 --60 * focus_loss_detach_minutes

-- Path to file that controls whether or not the window should detach.
-- local detach_timer_active_file = ""

-- Hides the terminal window if it remains unfocused for `focus_loss_detach_seconds`.
--
-- TODO: Figure out how to make this work properly. Right now, it always triggers the function
-- and detach the window after focus_loss_detach_seconds. The current idea is to use a file
-- (detach_timer_active_file) to control whether the callback should execute and detach or not.
--
-- wezterm.on("window-focus-changed", function(window, pane)
--   wezterm.log_info("window:is_focused() = " .. tostring(window:is_focused()))
--   wezterm.log_info("focus_loss_timer = " .. tostring(focus_loss_timer))
--
--   if window:is_focused() then
--     -- Window gained focus - cancel any pending detach
--
--     -- IDEA: Delete the detach_timer_active_file file.
--   else
--     -- Window lost focus - start a timer to detach after delay
--     wezterm.log_info("Window unfocused, starting detach timer for " .. focus_loss_detach_seconds .. " seconds")
--
--     -- IDEA: Create/update detach_timer_active_file file with the current time.
--
--     -- Create a timer using coroutine
--     wezterm.time.call_after(focus_loss_detach_seconds, function()
--       -- IDEA: Check if the detach_timer_active_file exists.
--       -- IDEA: If not, bail... timer has been cancelled.
--       -- IDEA: If so, check if the diff for current time is around focus_loss_detach_seconds,
--       -- IDEA: only proceeding if so (otherwise the timer was updated).
--
--       -- This will run after the specified delay if not cancelled
--       wezterm.log_info("Detach timer expired, detaching from tmux session")
--
--       -- Get the session name that's currently active
--       local success, stdout, stderr = wezterm.run_child_process({
--         "tmux",
--         "display-message",
--         "-p",
--         "#S",
--       })
--
--       local session_name
--       if success then
--         session_name = stdout:gsub("%s+", "") -- Trim whitespace
--         wezterm.log_info("Current tmux session: " .. session_name)
--
--         -- Now detach from this session
--         local detach_success, detach_stderr = wezterm.run_child_process({
--           "tmux",
--           "detach-client",
--           "-s",
--           session_name,
--         })
--
--         if not detach_success then
--           wezterm.log_error("Failed to detach from tmux: " .. tostring(detach_stderr))
--         else
--           wezterm.log_info("Successfully detached from tmux session: " .. session_name)
--         end
--       else
--         wezterm.log_error("Failed to get current tmux session: " .. tostring(stderr))
--       end
--
--       focus_loss_timer = nil
--     end)
--   end
-- end)

local function color_schemes_by_name(opts)
  setmetatable(opts, {
    __index = {
      -- Defaults to darker colors.
      min_light = 0.0,
      max_light = 0.4,
    },
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

local color_schemes_light = color_schemes_by_name({
  min_light = 0.6,
  max_light = 1.0,
})

local color_schemes_dark = color_schemes_by_name({
  min_light = 0.0,
  max_light = 0.2,
})

local color_schemes_to_pick = color_schemes_dark

-- Fill this as I find schemes that I like. Later I can randomize only them.
local color_scheme_override = {
  -- Use `false` to select a random color scheme or the index of the favorite to use as override.
  override = 27, -- 22, -- Update override.
  favorites = {
    "Dracula", -- Lua is 1-based, so this has index 1.
    "Dark Pastel", -- 2
    "CrayonPonyFish", -- 3
    "Heetch Dark (base16)", -- 4
    "Canvased Pastel (terminal.sexy)", -- 5
    "Synth Midnight Terminal Light (base16)", -- 6
    "midnight-in-mojave", -- 7
    "Slate (Gogh)", -- 8
    "tlh (terminal.sexy)", -- 9
    "Man Page (Gogh)", -- 10
    "Builtin Solarized Dark", -- 11
    "Apathy (base16)", -- 12
    "gooey (Gogh)", -- 13
    "SynthwaveAlpha (Gogh)", -- 14
    "Liquid Carbon Transparent (Gogh)", -- 15
    "Afterglow (Gogh)", -- 16
    "HaX0R_R3D", -- 17
    "Vice Alt (base16)", -- 18
    "Gigavolt (base16)", -- 19
    "Humanoid dark (base16)", -- 20
    "Nancy (terminal.sexy)", -- 21
    "Purpledream (base16)", -- 22
    "Mirage", -- 23
    "Solarized Dark Higher Contrast (Gogh)", -- 24
    "Trim Yer Beard (terminal.sexy)", -- 25
    "Gruvbox dark, hard (base16)", -- 26
    "Harmonic16 Dark (base16)", -- 27
    -- Next override.
  },
}

function get_scheme(opts)
  local scheme = "Dracula"

  if not opts.force_random and color_scheme_override.override then
    scheme = color_scheme_override.favorites[color_scheme_override.override]
    print("Overriden scheme: " .. scheme)
  else
    scheme = color_schemes_to_pick[math.random(#color_schemes_to_pick)]
    print("Random scheme: " .. scheme)
  end

  return scheme
end

wezterm.on("window-config-reloaded", function(window, pane)
  if not window:get_config_overrides() then
    window:set_config_overrides({
      color_scheme = get_scheme({ force_random = false }),
    })
  end
end)

-- next event

-- MAIN SETTINGS

config.window_background_opacity = 1
config.text_background_opacity = 1
config.window_decorations = "RESIZE"

local set_font = function(font)
  config.font = font.font
  config.font_size = font.size
  config.line_height = font.line_height or 1.0
end

set_font(fonts.noto)
set_font(fonts.jb)
set_font(fonts.jb_nf)

config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"
-- config.freetype_load_flags = 'NO_HINTING'

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
  cursor_bg = "#ff4500", -- orange red (supposed to work with light/dark themes).
  cursor_fg = "black",
}

-- The x is calculated as `(screen_width + panel_width) / 2`. See `gui-startup`
-- above.
config.default_gui_startup_args = { "start", "--position", "1303,0", SCRATCH_SCRIPT }

local should_blink = false
if should_blink then
  config.default_cursor_style = "BlinkingUnderline"
  config.cursor_thickness = "0.1pt"
  config.cursor_blink_rate = 500
else
  config.default_cursor_style = "SteadyUnderline"
end

-- KEYBINDINGS

function change_color_scheme(window, pane)
  wezterm.gui.gui_windows()[1]:set_config_overrides({ color_scheme = get_scheme({ force_random = true }) })
end

config.keys = {
  { key = "h", mods = "SHIFT|CTRL", action = wezterm.action.Search({ Regex = "hello" }) },
  { key = "j", mods = "ALT|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "k", mods = "ALT|SHIFT", action = act.ActivateTabRelative(1) },
  { key = "t", mods = "SHIFT|ALT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "t", mods = "SHIFT|CTRL", action = wezterm.action_callback(change_color_scheme) },
}

-- RETURN THE CONFIG OBJECT, TO APPLY ALL SETTINGS

return config
