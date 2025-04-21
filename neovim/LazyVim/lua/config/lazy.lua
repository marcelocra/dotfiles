local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  colorscheme = function()
    -- Load the colorscheme, choosing the mode: 'time_based', 'dark', 'light'.
    -- time_based: the colorscheme will be chosen based on the time of the day.

    vim.g.colorscheme_modes = { "time_based", "dark", "light" }
    vim.g.colorscheme_mode = vim.g.colorscheme_modes[1]

    math.randomseed(os.time())

    -- For dark mode, choose randomly between these options:
    local dark_mode_options = {
      -- -- These are nice, but with at least one weird color.
      -- 'sorbet',  -- telescope thingy is weird grey
      -- 'zaibatsu',  -- telescope thingy is weird light grey
      -- 'vim',  -- accent color is bright pink that hurt my eyes (and I like pink)
      -- 'goodwolf',  -- very few colors...
      -- --

      -- 'habamax', -- a bit dead, but still nice
      -- 'badwolf',  -- classic and still good!
      -- 'retrobox',  -- interesting... badwolf vibes
      -- 'vividchalk', -- really vivid!
      -- 'wildcharm', -- kind of vivid too, though less than vividchalk
      "tokyonight-night", -- so good!
      "tokyonight-storm", -- so good too!
      "tokyonight-moon", -- so good three!
      -- 'catppuccin-frappe',
      -- 'catppuccin-macchiato',
      -- 'catppuccin-mocha',
    }
    vim.g.colorscheme_mode_dark = dark_mode_options[math.random(#dark_mode_options)]

    -- For light mode, choose randomly between these options:
    local light_mode_options = {
      "tokyonight-day",
      "catppuccin-latte",
    }
    vim.g.colorscheme_mode_light = light_mode_options[math.random(#light_mode_options)]

    --[[
      Adjust your colorscheme based on the time of the day (light: day, dark: night),
      with an override for when it is necessary (e.g. a very bright room at night).
      --]]

    local hour_now = tonumber(os.date("%H"))
    local daylight_ends = 17
    local daylight_starts = 5

    local dark = "dark" -- Override with a dark mode of your choice.
    local light = "light" -- Override with a light mode of your choice.

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

    vim.cmd.colorscheme(define_colorscheme())

    local transparent_background = function()
      -- vim.cmd 'hi Normal guibg=NONE ctermbg=NONE'
    end

    transparent_background()

    -- Simplify toggling light and dark.
    vim.keymap.set("n", "<M-d>", function()
      vim.cmd.colorscheme(define_colorscheme("dark"))
      transparent_background()
    end, { desc = "Set colorscheme to vim.g.colorscheme_mode_dark" })
    vim.keymap.set("n", "<M-l>", function()
      vim.cmd.colorscheme(define_colorscheme("light"))
      transparent_background()
    end, { desc = "Set colorscheme to vim.g.colorscheme_mode_light" })
  end,
})
