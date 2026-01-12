# Neovim Configuration (LazyVim Starter)

## Project Overview
This project is a Neovim configuration based on the [LazyVim](https://github.com/LazyVim/LazyVim) starter template. It provides a structured, modular foundation for a modern Neovim setup, utilizing [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager.

## Key Technologies
*   **Neovim:** The text editor itself (requires 0.9.0+).
*   **Lua:** The configuration language.
*   **LazyVim:** A configuration framework providing sensible defaults and plugin integrations.
*   **lazy.nvim:** A modern plugin manager for Neovim.

## File Structure & Organization
The configuration follows a standard Lua module structure rooted in the `lua/` directory.

### Entry Point
*   **`init.lua`**: The main entry point. It simply bootstraps the configuration by requiring `config.lazy`.

### Configuration (`lua/config/`)
Core Neovim settings are isolated here to keep the setup clean.
*   **`lazy.nvim`**: Bootstraps the plugin manager and loads plugins.
*   **`options.lua`**: Sets Neovim options (e.g., line numbers, tabs) *before* plugins are loaded.
*   **`keymaps.lua`**: Defines custom keybindings. Loaded on the `VeryLazy` event (after startup).
*   **`autocmds.lua`**: Defines autocommands (automatic event handlers).
*   **`lazy.lua`**: Configures `lazy.nvim`, imports the core LazyVim plugins, and loads user plugins from the `lua/plugins/` directory.

### Plugins (`lua/plugins/`)
*   **`example.lua`**: A reference file demonstrating how to add, configure, disable, or override plugins. **Note:** This file is currently disabled by a guard clause (`if true then return {} end`).
*   **User Plugins:** Any new `.lua` file created in this directory will be automatically loaded by `lazy.nvim` as a plugin specification.

## Usage & Customization

### Adding Plugins
Create a new file in `lua/plugins/` (e.g., `lua/plugins/my-plugins.lua`) and return a table of plugin specifications.
```lua
return {
  { "mona/qa", opts = { color = "yellow" } },
}
```

### Configuring Options
Edit `lua/config/options.lua` to change standard Neovim settings.
```lua
vim.opt.relativenumber = true
```

### Keymaps
Edit `lua/config/keymaps.lua` to add global keybindings.
```lua
vim.keymap.set("n", "<leader>hw", "<cmd>echo 'Hello World'<cr>")
```

## Building and Running
Since this is a configuration for an editor, there is no "build" step.
1.  **Install:** Ensure Neovim is installed.
2.  **Run:** Execute `nvim` in your terminal.
3.  **Bootstrap:** On the first launch, `lazy.nvim` will automatically clone itself and install all defined plugins.
