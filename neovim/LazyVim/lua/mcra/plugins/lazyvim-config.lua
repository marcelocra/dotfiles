return {
  {
    "saghen/blink.cmp",
    dependencies = { "saghen/blink.compat", "hrsh7th/cmp-emoji" },

    opts = {
      appearance = {
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- adjusts spacing to ensure icons are aligned.
        nerd_font_variant = "mono",
      },

      sources = {
        compat = { "emoji" },
      },

      keymap = {
        -- Go back to using <Tab> and <S-Tab> for most things, like in VSCode.
        -- Docs: https://cmp.saghen.dev/configuration/keymap.html#super-tab
        preset = "super-tab",
      },
    },
  },

  {
    "folke/snacks.nvim",

    ---@type snacks.Config
    opts = {
      profiler = { enabled = false },
      notifier = {
        ---@type snacks.notifier.style
        style = "fancy",

        width = { min = 40, max = 0.4 },
        height = { min = 1, max = 0.6 },
        -- Try bottom left.
        margin = { top = 0, left = 1, bottom = 1, right = 0 },
      },

      scratch = {
        win = {
          relative = "editor",
          position = "right",
          width = 0.3,
          height = 1.0,
        },
      },
    },

    keys = {
      { "<Leader>e", false },
      { "<Leader>dpp", false },
      { "<Leader>dph", false },
      { "<Leader>dps", false },
    },
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    keys = {
      { "s", false, mode = { "o" } },
      { "S", false, mode = { "o" } },
    },
  },

  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        {
          -- mode = { "n", "v" },
          -- { "<leader><tab>", group = "tabs" },
          -- { "<leader>c", group = "code" },
          { "<leader>d", hidden = false },
          -- { "<leader>dp", group = "profiler" },
          -- { "<leader>f", group = "file/find" },
          -- { "<leader>g", group = "git" },
          -- { "<leader>gh", group = "hunks" },
          -- { "<leader>q", group = "quit/session" },
          -- { "<leader>s", group = "search" },
          -- { "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
          -- { "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
          -- { "[", group = "prev" },
          -- { "]", group = "next" },
          -- { "g", group = "goto" },
          -- { "gs", group = "surround" },
          -- { "z", group = "fold" },
          -- {
          --   "<leader>b",
          --   group = "buffer",
          --   expand = function()
          --     return require("which-key.extras").expand.buf()
          --   end,
          -- },
          -- {
          --   "<leader>w",
          --   group = "windows",
          --   proxy = "<c-w>",
          --   expand = function()
          --     return require("which-key.extras").expand.win()
          --   end,
          -- },
          -- -- better descriptions
          -- { "gx", desc = "Open with system app" },
        },
      },
    },
    -- keys = {
    --   {
    --     "<leader>?",
    --     function()
    --       require("which-key").show({ global = false })
    --     end,
    --     desc = "Buffer Keymaps (which-key)",
    --   },
    --   {
    --     "<c-w><space>",
    --     function()
    --       require("which-key").show({ keys = "<c-w>", loop = true })
    --     end,
    --     desc = "Window Hydra Mode (which-key)",
    --   },
    -- },
    -- config = function(_, opts)
    --   local wk = require("which-key")
    --   wk.setup(opts)
    --   if not vim.tbl_isempty(opts.defaults) then
    --     LazyVim.warn("which-key: opts.defaults is deprecated. Please use opts.spec instead.")
    --     wk.register(opts.defaults)
    --   end
    -- end,
  },
}
