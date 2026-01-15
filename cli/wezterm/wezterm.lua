-- WezTerm Configuration
-- Optimized for SSH, Multiplexers, and Development Workflows

local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

-- ============================================================================
-- PERFORMANCE & RENDERING
-- ============================================================================

-- Use WebGpu for best performance on modern systems
-- If you experience crashes, change to "OpenGL"
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
config.max_fps = 60

-- Scrollback: 20k lines for history depth
config.scrollback_lines = 20000

-- ============================================================================
-- THEME & VISUALS
-- ============================================================================

-- config.color_scheme = "Catppuccin Mocha"
config.color_scheme = "Tokyo Night Storm"

-- Solid background for best performance (no compositing overhead)
config.window_background_opacity = 1.0

-- Windows-specific: Native Acrylic effect (Optional. Disable for performance)
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  -- config.win32_system_backdrop = "Acrylic"
  -- config.window_background_opacity = 0.95
end

config.window_decorations = "TITLE | RESIZE"

-- ============================================================================
-- FONT CONFIGURATION
-- ============================================================================

config.font = wezterm.font("Cascadia Code NF")
config.font_size = 13.0
config.line_height = 1.0

-- Enable programming ligatures with Cascadia Code stylistic sets
config.harfbuzz_features = { "calt=1", "ss01=1", "ss19=1", "ss20=1" }

-- Font rendering optimization for crispness on high-DPI displays
config.freetype_load_target = "Light"
-- config.freetype_render_target = "HorizontalLcd"
config.freetype_load_flags = "NO_HINTING"

-- ============================================================================
-- WINDOW & LAYOUT
-- ============================================================================

config.window_padding = {
  left = 40,
  right = 40,
  top = 30,
  bottom = 30,
}

config.initial_cols = 120
config.initial_rows = 30

-- ============================================================================
-- TABS
-- ============================================================================

config.enable_tab_bar = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

-- Tab bar font and size
config.window_frame = {
  font = wezterm.font('Cascadia Mono NF'),
  font_size = 10,
}

-- ============================================================================
-- CURSOR
-- ============================================================================

-- Steady cursor (no blinking - better for accessibility and screenshots)
config.default_cursor_style = "SteadyUnderline"
config.cursor_thickness = "200%"

-- ============================================================================
-- HYPERLINKS & QUICK SELECT - Auto-detect URLs, file paths, etc.
-- ============================================================================

config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- GitHub/GitLab paths
table.insert(config.hyperlink_rules, {
  regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)[":]?]],
  format = "https://github.com/$1/$3",
})

-- Localhost URLs
table.insert(config.hyperlink_rules, {
  regex = [[\blocalhost:\d+\b]],
  format = "http://$0",
})

-- Log file paths
table.insert(config.hyperlink_rules, {
  regex = [[/[\w\d\.\-_/]+\.(log|txt|md|json|yaml|yml|toml|conf|cfg)]],
  format = "file://$0",
})

-- Patterns for Quick Select (Leader + Space)
config.quick_select_patterns = {
  -- URLs (Full)
  "https?://\\S+",

  -- IPs
  "\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b",

  -- Emails
  "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}",

  -- Hashes
  "\\b[0-9a-f]{7,40}\\b",

  -- UUIDs
  "\\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\\b",

  -- Resource names (Improved)
  "\\b[a-zA-Z0-9][-a-zA-Z0-9_.]*[a-zA-Z0-9]\\b",

  -- Container IDs
  "\\b[0-9a-f]{12}\\b",
}

-- ============================================================================
-- KEY BINDINGS - Optimized for SSH workflow
-- ============================================================================

-- Leader key: Make it different from your multiplexer's leader
config.leader = { key = "q", mods = "ALT", timeout_milliseconds = 1000 }

config.keys = {
  -- Pane Navigation (Local WezTerm panes)
  {
    key = "-",
    mods = "LEADER",
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "\\",
    mods = "LEADER",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  {
    key = "x",
    mods = "LEADER",
    action = act.CloseCurrentPane({ confirm = true }),
  },

  -- Pane Resizing
  {
    key = "LeftArrow",
    mods = "LEADER",
    action = act.AdjustPaneSize({ "Left", 5 }),
  },
  {
    key = "RightArrow",
    mods = "LEADER",
    action = act.AdjustPaneSize({ "Right", 5 }),
  },
  {
    key = "UpArrow",
    mods = "LEADER",
    action = act.AdjustPaneSize({ "Up", 5 }),
  },
  {
    key = "DownArrow",
    mods = "LEADER",
    action = act.AdjustPaneSize({ "Down", 5 }),
  },

  -- Utilities
  { key = "Space", mods = "LEADER", action = act.QuickSelect }, -- Grab text from screen
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode }, -- Vim-mode scrolling
  {
    key = "f",
    mods = "CTRL|SHIFT",
    action = act.Search("CurrentSelectionOrEmptyString"),
  },
  {
    key = "k",
    mods = "CTRL|SHIFT",
    action = act.ClearScrollback("ScrollbackAndViewport"),
  },
  { key = "l", mods = "CTRL|SHIFT", action = act.ShowLauncher }, -- SSH Launcher
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },

  -- Font Sizing
  { key = "+", mods = "CTRL", action = act.IncreaseFontSize },
  { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
  { key = "0", mods = "CTRL", action = act.ResetFontSize },
}

-- ============================================================================
-- COPY & SEARCH MODE - Vim-like keybindings
-- ============================================================================

config.key_tables = {
  copy_mode = {
    { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
    { key = "q", mods = "NONE", action = act.CopyMode("Close") },

    -- Movement
    { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
    { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
    { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
    { key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
    { key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
    { key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
    {
      key = "$",
      mods = "NONE",
      action = act.CopyMode("MoveToEndOfLineContent"),
    },

    -- Page movement
    { key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
    {
      key = "G",
      mods = "NONE",
      action = act.CopyMode("MoveToScrollbackBottom"),
    },
    { key = "d", mods = "CTRL", action = act.CopyMode("PageDown") },
    { key = "u", mods = "CTRL", action = act.CopyMode("PageUp") },

    -- Selection
    {
      key = "v",
      mods = "NONE",
      action = act.CopyMode({ SetSelectionMode = "Cell" }),
    },
    {
      key = "V",
      mods = "NONE",
      action = act.CopyMode({ SetSelectionMode = "Line" }),
    },
    {
      key = "v",
      mods = "CTRL",
      action = act.CopyMode({ SetSelectionMode = "Block" }),
    },

    -- Copy
    {
      key = "y",
      mods = "NONE",
      action = act.Multiple({
        { CopyTo = "ClipboardAndPrimarySelection" },
        { CopyMode = "Close" },
      }),
    },

    -- Search
    {
      key = "/",
      mods = "NONE",
      action = act.Search("CurrentSelectionOrEmptyString"),
    },
    { key = "n", mods = "NONE", action = act.CopyMode("NextMatch") },
    { key = "N", mods = "NONE", action = act.CopyMode("PriorMatch") },
  },

  search_mode = {
    { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
    { key = "Enter", mods = "NONE", action = act.CopyMode("PriorMatch") },
    { key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
    { key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
    { key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
    { key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
  },
}

-- ============================================================================
-- LAUNCH MENU
-- ============================================================================

config.launch_menu = {
  {
    label = "PowerShell 7",
    args = { "pwsh.exe", "-NoLogo" },
  },
  {
    label = "PowerShell 5",
    args = { "powershell.exe", "-NoLogo" },
  },
  {
    label = "Command Prompt",
    args = { "cmd.exe" },
  },
  {
    label = "WSL",
    args = { "wsl.exe", "--cd", "~" },
  },
}

-- ============================================================================
-- SHELL DETECTION
-- ============================================================================

-- Platform-specific default shell
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  -- Windows: Prefer PowerShell Core (pwsh), fall back to native PowerShell
  local success, stdout = wezterm.run_child_process({ "where", "pwsh.exe" })
  if success and stdout ~= "" then
    config.default_prog = { "pwsh.exe", "-NoLogo" }
  else
    config.default_prog = { "powershell.exe", "-NoLogo" }
  end
else
  -- Unix-like systems: Check for common shells in order of preference
  local shells = { "zsh", "bash", "pwsh", "fish" }
  for _, shell in ipairs(shells) do
    local success, stdout = wezterm.run_child_process({ "which", shell })
    if success and stdout ~= "" then
      config.default_prog = { shell }
      break
    end
  end

  -- Fallback to bash if none found
  if not config.default_prog then
    config.default_prog = { "/bin/bash" }
  end
end

-- ============================================================================
-- MOUSE & NOTIFICATIONS
-- ============================================================================

config.hide_mouse_cursor_when_typing = true

config.mouse_bindings = {
  {
    -- Right click: Copy if selection exists, else Paste
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ""
      if has_selection then
        window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act.PasteFrom("Clipboard"), pane)
      end
    end),
  },

  {
    -- Open hyperlinks with Ctrl+Click
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },
}

-- Visual bell for long-running commands
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_function = "EaseIn",
  fade_in_duration_ms = 150,
  fade_out_function = "EaseOut",
  fade_out_duration_ms = 150,
}

-- ============================================================================
-- MISCELLANEOUS
-- ============================================================================

config.automatically_reload_config = true

-- Set working directory to home on new panes
config.default_cwd = wezterm.home_dir

-- Confirm before closing window with running programs
-- "NeverPrompt" since using a multiplexer
config.window_close_confirmation = "NeverPrompt"

-- Enable modern keyboard protocol for better key handling over SSH
config.enable_kitty_keyboard = true

return config
