return {
  -- Extend auto completion.
  {
    "saghen/blink.cmp",
    dependencies = { "saghen/blink.compat", "marcelocra/cmp-conjure" },
    -- TODO: Try adding "clojure" to `compat` and see if it improves.
    opts = { sources = { compat = { "conjure" } } },
  },

  -- Replaces vim-sexp with *-mappings-for-regular-people.
  {
    "marcelocra/nvim-treesitter-sexp",
    dependencies = {
      -- Add Clojure and related to treesitter.
      {
        "nvim-treesitter/nvim-treesitter",
        -- Contributed by sogaiu and borkdude, both with multiple contributions
        -- in the community. Code: https://github.com/sogaiu/tree-sitter-clojure
        opts = { ensure_installed = { "clojure" } },
      },
    },

    -- INFO: Supported languages. For others, fallback to the ones below.
    ft = { "clojure", "fennel", "janet", "query" },
    lazy = true,
    opts = {
      keymaps = {
        motions = {
          prev_top_level = "[r",
          next_top_level = "]r",
        },
      },
    },
  },

  -- Better Lisp (s-exp) support.
  {
    "guns/vim-sexp",
    ft = { "racket" },
    lazy = true,
    config = function()
      -- 'vim-sexp' defaults that use Alt (M).
      -- <M-k>      *<Plug>(sexp_swap_list_backward)*
      -- <M-j>      *<Plug>(sexp_swap_list_forward)*
      -- <M-h>      *<Plug>(sexp_swap_element_backward)*
      -- <M-l>      *<Plug>(sexp_swap_element_forward)*
      -- <M-S-j>    *<Plug>(sexp_emit_head_element)*
      -- <M-S-k>    *<Plug>(sexp_emit_tail_element)*
      -- <M-S-h>    *<Plug>(sexp_capture_prev_element)*
      -- <M-S-l>    *<Plug>(sexp_capture_next_element)*

      -- Ignore them to avoid conflict with my preferred mappings. Use the
      -- vim-sexp-mappings-for-regular-people keybindings instead.
      vim.g["sexp_mappings"] = {
        ["sexp_swap_list_backward"] = "",
        ["sexp_swap_list_forward"] = "",
        ["sexp_swap_element_backward"] = "",
        ["sexp_swap_element_forward"] = "",
        ["sexp_emit_head_element"] = "",
        ["sexp_emit_tail_element"] = "",
        ["sexp_capture_prev_element"] = "",
        ["sexp_capture_next_element"] = "",

        -- These doesn't seem to be working.
        ["sexp_insert_double_quote"] = "",
        ["sexp_insert_backspace"] = "",
      }
    end,
  },

  -- Better Lisp (s-exp) mappings.
  {
    "tpope/vim-sexp-mappings-for-regular-people",
    ft = { "racket" },
    lazy = true,
  },

  -- Colorize the output of the log buffer.
  {
    "marcelocra/baleia.nvim",
    lazy = true,
    opts = {
      line_starts_at = 3,
    },
    config = function(_, opts)
      vim.g.conjure_baleia = require("baleia").setup(opts)

      vim.api.nvim_create_user_command("BaleiaColorize", function()
        vim.g.conjure_baleia.once(vim.api.nvim_get_current_buf())
      end, { bang = true })

      vim.api.nvim_create_user_command("BaleiaLogs", vim.g.conjure_baleia.logger.show, { bang = true })
    end,
  },

  -- Clojure, Lisps, Python, etc, REPL support in Neovim.
  {
    "Olical/conjure",
    dependencies = {
      -- "marcelocra/cmp-conjure",
      -- "marcelocra/baleia.nvim",
      -- {
      --   "LazyVim/LazyVim",
      --
      --   keys = {
      --     { "]]", false },
      --     { "[[", false },
      --   },
      --
      --   init = function()
      --     --
      --     -- Remove some LazyVim default mappings before loading Conjure's.
      --     --
      --
      --     vim.keymap.del("n", "]]")
      --     vim.keymap.del("n", "[[")
      --   end,
      -- },
    },

    ft = { "clojure", "edn", "fennel", "python", "racket", "lua" },
    lazy = true,

    init = function()
      --
      -- LazyExtras Clojure config.
      --

      -- print color codes if baleia.nvim is available
      local colorize = require("lazyvim.util").has("baleia.nvim")

      if colorize then
        vim.g["conjure#log#strip_ansi_escape_sequences_line_limit"] = 0
      else
        vim.g["conjure#log#strip_ansi_escape_sequences_line_limit"] = 1
      end

      -- disable diagnostics in log buffer and colorize it
      vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
        pattern = "conjure-log-*",
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          vim.diagnostic.enable(false, { bufnr = buffer })

          if colorize and vim.g.conjure_baleia then
            vim.g.conjure_baleia.automatically(buffer)
          end

          vim.keymap.set(
            { "n", "v" },
            "[c",
            "<CMD>call search('^; -\\+$', 'bw')<CR>",
            { silent = true, buffer = true, desc = "Jumps to the begining of previous evaluation output." }
          )
          vim.keymap.set(
            { "n", "v" },
            "]c",
            "<CMD>call search('^; -\\+$', 'w')<CR>",
            { silent = true, buffer = true, desc = "Jumps to the begining of next evaluation output." }
          )
        end,
      })

      -- prefer LSP for jump-to-definition and symbol-doc, and use conjure
      -- alternatives with <localleader>K and <localleader>gd
      vim.g["conjure#mapping#doc_word"] = "K"
      vim.g["conjure#mapping#def_word"] = "gd"

      --
      -- My previous configs.
      --

      -- Uncomment this to get verbose logging to help diagnose internal Conjure
      -- issues. This is VERY helpful when reporting an issue with the project.
      -- vim.g["conjure#debug"] = true

      vim.g["conjure#extract#tree_sitter#enabled"] = true

      -- vim.g['conjure#client_on_load'] = false
      vim.g["conjure#log#jump_to_latest#enabled"] = true
      vim.g["conjure#log#jump_to_latest#cursor_scroll_position"] = "center"

      vim.g["conjure#log#wrap"] = true

      vim.g["conjure#log#hud#anchor"] = "SE"
      vim.g["conjure#log#hud#width"] = 1.0

      vim.g["conjure#log#botright"] = true
      -- vim.g['conjure#log#fold#enabled'] = true

      vim.g["conjure#highlight#enabled"] = true

      -- NOTE: Uses clj with nrepl instead of babashka. Requires an alias named
      -- :repl/conjure in ~/.clojure/deps.edn (mine is in the root of this
      -- repo).
      -- vim.g["conjure#client#clojure#nrepl#connection#auto_repl#cmd"] = "clj -M:repl/conjure"
    end,

    config = function()
      --
      -- Load Conjure defaults.
      --

      require("conjure.main").main()
      require("conjure.mapping")["on-filetype"]()

      --
      -- Alternative evaluation mappings for Conjure.
      --

      -- Word mappings (w).
      vim.keymap.set({ "n" }, "<S-CR>", "<LocalLeader>ew", { silent = true, remap = true })
      vim.keymap.set({ "n" }, "<M-S-CR>", "<LocalLeader>ecw", { silent = true, remap = true })
      vim.keymap.set({ "i" }, "<S-CR>", "<Esc><LocalLeader>ewa", { silent = true, remap = true })
      vim.keymap.set({ "i" }, "<M-S-CR>", "<Esc><LocalLeader>ecwa", { silent = true, remap = true })

      -- Line mappings (e).
      vim.keymap.set({ "n" }, "<C-CR>", "<LocalLeader>ee", { silent = true, remap = true })
      vim.keymap.set({ "n" }, "<M-C-CR>", "<LocalLeader>ece", { silent = true, remap = true })
      vim.keymap.set({ "i" }, "<C-CR>", "<Esc><LocalLeader>eea", { silent = true, remap = true })
      vim.keymap.set({ "i" }, "<M-C-CR>", "<Esc><LocalLeader>ecea", { silent = true, remap = true })

      -- Root mappings (r).
      vim.keymap.set({ "n" }, "<M-CR>", "<LocalLeader>er", { silent = true, remap = true })
      vim.keymap.set({ "n" }, "<C-S-M-CR>", "<LocalLeader>ecr", { silent = true, remap = true })
      vim.keymap.set({ "i" }, "<M-CR>", "<Esc><LocalLeader>era", { silent = true, remap = true })
      vim.keymap.set({ "i" }, "<C-S-M-CR>", "<Esc><LocalLeader>ecra", { silent = true, remap = true })

      -- Visual mappings.
      vim.keymap.set({ "v" }, "<C-CR>", "<LocalLeader>E", { silent = true, remap = true })
      vim.keymap.set({ "v" }, "<M-CR>", "<LocalLeader>e!", { silent = true, remap = true })
    end,

    -- -- TODO: Try to make this work.
    -- keys = {
    --   { "<M-j>", false },
    --   { "<M-k>", false },
    --
    --   -- Alternative evaluation mappings. {{{
    --
    --   { "<S-CR>", mode = { "n" }, "<LocalLeader>ew" },
    --   { "<M-S-CR>", mode = { "n" }, "<LocalLeader>ecw" },
    --   { "<S-CR>", mode = { "i" }, "<Esc><LocalLeader>ewa" },
    --   { "<M-S-CR>", mode = { "i" }, "<Esc><LocalLeader>ecwa" },
    --
    --   { "<C-CR>", mode = { "n" }, "<LocalLeader>ee" },
    --   { "<M-C-CR>", mode = { "n" }, "<LocalLeader>ece" },
    --   { "<C-CR>", mode = { "i" }, "<Esc><LocalLeader>eea" },
    --   { "<M-C-CR>", mode = { "i" }, "<Esc><LocalLeader>ecea" },
    --
    --   { "<M-CR>", mode = { "n" }, "<LocalLeader>er" },
    --   { "<C-S-M-CR>", mode = { "n" }, "<LocalLeader>ecr" },
    --   { "<M-CR>", mode = { "i" }, "<Esc><LocalLeader>era" },
    --   { "<C-S-M-CR>", mode = { "i" }, "<Esc><LocalLeader>ecra" },
    --
    --   { "<C-CR>", mode = { "v" }, "<LocalLeader>E" },
    --   { "<M-CR>", mode = { "v" }, "<LocalLeader>e!" },
    --
    --   -- }}}
    --
    -- },
  },
}
