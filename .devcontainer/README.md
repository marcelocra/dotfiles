# Development Container Configuration

This project uses a devcontainer for consistent development environments.

## Quick Start

1. **Open in VS Code**: Install the Dev Containers extension
2. **Reopen in container**: `F1` → "Dev Containers: Reopen in Container"
3. **Wait for setup**: The container will build and configure automatically

### With Compose Services

```bash
# Tell VS Code to use the compose version
code your-project
# Then: F1 → "Dev Containers: Open Folder in Container..."
# Select: .devcontainer/compose/devcontainer.json
```

Or create a VS Code workspace file:

```json
// your-project.code-workspace
{
  "folders": [
    {
      "path": "."
    }
  ],
  "settings": {
    "remote.containers.configFilePaths": [
      ".devcontainer/compose/devcontainer.json"
    ]
  }
}
```

## What Gets Installed

- **Base**: Universal development image with multiple language runtimes
- **User**: Custom user `marcelo` with zsh and oh-my-zsh
- **Dotfiles**: Automatically cloned and configured from [marcelocra/dotfiles](https://github.com/marcelocra/dotfiles)
- **SSH**: Host SSH keys are mounted for Git operations
- **Tools**: GitHub CLI, Gemini CLI, Claude CLI credentials mounted

## Customization

You can customize the setup by modifying environment variables in `devcontainer.json`:

```json
"containerEnv": {
  "MCRA_SETUP_DOTFILES": "false",     // Skip dotfiles if using VS Code dotfiles
  "MCRA_SETUP_VSCODE": "false",       // Skip VS Code config setup
  "MCRA_SETUP_SUBLIME": "false",      // Skip Sublime Text config setup
  "MCRA_SETUP_ZED": "false"           // Skip Zed config setup
}
```

## Ports

- `11434` - Ollama API (for local LLM development)

## Troubleshooting

- **SSH issues**: Make sure your SSH keys are in `~/.ssh` on the host
- **Dotfiles not loading**: Check the container logs: `F1` → "Dev Containers: Show Container Log"
- **Rebuild needed**: `F1` → "Dev Containers: Rebuild Container"
