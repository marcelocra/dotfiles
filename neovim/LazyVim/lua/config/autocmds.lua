-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Simplify the creation of autocommand groups.
local group = function(name)
  return vim.api.nvim_create_augroup("my-autocmds-" .. name, { clear = true })
end

-- vim.api.nvim_create_autocmd("FileType", {
--   desc = "Run line or selection through external shell and paste output in current buffer",
--   pattern = { "sh" },
--   group = group("run-line-or-selection-external-shell"),
--   callback = function()
--     local u = require("utils")
--     -- NOTE: Test with: echo hello world (select "echo hello")
--     -- TODO: Deal with ^M (carriage return) characters. Currently they break the command.
--     u.nmap(
--       "<Leader>ee",
--       ":exec 'r !' . getline('.')<CR>",
--       "Run current line in external shell and paste the output below"
--     )
--     u.vmap("<Leader>E", '"xy:r ! <C-r>x<CR>', "Run selection in external shell and paste the output below")
--   end,
-- })

-- vim.api.nvim_create_autocmd("VimEnter", {
--   desc = "Example",
--   group = group("example"),
--   callback = function()
--     -- Do stuff here.
--   end,
-- })

-- vim.api.nvim_create_autocmd("VimEnter", {
--   desc = "Ensure that all required plugins for LSP are installed",
--   group = group("ensure-lsp-plugins"),
--   callback = function()
--   end,
-- })

local force_custom_formatoptions = function(enable) -- {{{
  if not enable then
    return
  end

  vim.api.nvim_create_autocmd("FileType", {
    desc = "Forces format options.",
    group = group("set-formatoptions"),
    pattern = "*",
    callback = function()
      vim.opt_local.formatoptions = "jcroqn"
    end,
  })
end -- }}}

vim.g.mcra_tw_comments = 80

local dynamically_set_text_width = function(enable) -- {{{
  if not enable then
    return
  end

  vim.api.nvim_create_autocmd("BufWinEnter", {
    desc = "Sets different textwidth for comments. Otherwise it is controlled by EditorConfig.",
    group = group("dynamic-text-width"),
    pattern = "*",
    callback = function()
      local the_regex = "^%s*[%-%/#{%(][%-%*%(]?"
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = group("dynamic-text-width-cursor-moved"),
        buffer = 0,
        callback = function()
          local line = vim.api.nvim_get_current_line()
          local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1
          local before_cursor = line:sub(1, cursor_col)

          -- Lua patterns are different from regex.
          --    ^ and *: same as in regex
          --    %s: all whitespace
          --    %/ %* # ; %- %! %(: literal characters
          --    [...]: a char set (same as regex)
          --
          -- First try: '^%s*[%/]?[%/%*#;%-%-%!]'
          --
          --    Didn't work very well, particularly for Lua comments. Lets write this a bit more and
          --
          -- Second try: '^%s*[%-%/#{%(][%-%*%(]?'
          --
          --    Should match most line and block comments.
          --    Line comments:
          --      --: Lua, Haskell
          --      //: C-like: C, C++, Java, JavaScript, etc.
          --      # : Python, Ruby, Shell, etc.
          --    Block comment starts:
          --      /*: C-like block comment start
          --      { : Pascal-style
          --      (*: ML-style
          if before_cursor:match(the_regex) then
            -- If inside a comment, update tw.
            vim.opt_local.textwidth = vim.g.mcra_tw_comments
          end
        end,
      })

      -- If user presses gq, do the same as above.
      vim.api.nvim_create_autocmd("FileType", {
        group = group("dynamic-text-width-gq"),
        -- should be enabled for the same filetypes above.
        pattern = { "*.lua" },
        callback = function()
          local function _helper()
            local line = vim.api.nvim_get_current_line()
            local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1
            local before_cursor = line:sub(1, cursor_col)

            if before_cursor:match(the_regex) then
              vim.opt_local.textwidth = vim.g.mcra_tw_comments
            end
          end
          vim.keymap.set("n", "gqq", _helper, { desc = "Change default textwidth for comments" })
          vim.keymap.set("v", "gq", _helper, { desc = "Change default textwidth for comments" })
        end,
      })
    end,
  })
end -- }}}

local auto_save = function(enable) -- {{{
  if not enable then
    return
  end

  local function clear_cmdarea()
    vim.defer_fn(function()
      vim.api.nvim_echo({}, false, {})
    end, 800)
  end

  local auto_save_triggers = {
    "InsertLeave",
    -- 'TextChanged',  -- This one seems too aggressive.
  }

  vim.api.nvim_create_autocmd(auto_save_triggers, {
    desc = "Automatically save changes.",
    group = group("auto-save-changes"),
    callback = function()
      if #vim.api.nvim_buf_get_name(0) ~= 0 and vim.bo.buflisted then
        vim.cmd("silent w")

        local time = os.date("%H:%M:%S")

        -- print nice colored msg
        vim.api.nvim_echo({ { "v", "LazyProgressDone" }, { " file autosaved at " .. time } }, false, {})

        clear_cmdarea()
      end
    end,
  })
end -- }}}

force_custom_formatoptions(false)
dynamically_set_text_width(false)
auto_save(false)
