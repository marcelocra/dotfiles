# Cursor Configuration

This directory contains Cursor settings, keybindings, snippets, and other configuration files.

This configuration was originally based on VS Code settings but has been cleaned up to remove VS Code-specific features and keep only Cursor-relevant settings.

## VS Code-Specific Settings Removed

The following VS Code-specific settings have been removed from `settings.json`:

### Azure & Microsoft Services
- `@azure.argTenant` - Azure argument tenant setting
- `ms-azuretools.vscode-azure-github-copilot` - Azure GitHub Copilot extension reference

### Remote Development & Dev Containers
- `dev.containers.dockerComposePath` - Dev Containers Docker Compose path
- `dev.containers.dockerPath` - Dev Containers Docker path
- `dev.containers.mountWaylandSocket` - Dev Containers Wayland socket mounting
- `remote.autoForwardPortsSource` - Remote port forwarding configuration

### VS Code-Specific Extensions
- `chatgpt.runCodexInWindowsSubsystemForLinux` - ChatGPT extension setting
- `dotnetAcquisitionExtension.*` - .NET acquisition extension settings (including Azure Copilot extension reference)
- `gitlens.ai.vscode.model` - GitLens VS Code-specific AI model configuration

### Other
- `explorer.z next` - Incomplete/invalid explorer setting

## Extensions Not Available in Cursor

The following VS Code extensions are not available in Cursor:

- `ms-vscode-remote.remote-ssh-edit`
- `ms-vscode.vscode-speech`
- `ms-vscode-remote.vscode-remote-extensionpack`
- `vercel.turbo-vsc`
- `ms-azuretools.vscode-containers`
- `github.codespaces`
- `ms-windows-ai-studio.windows-ai-studio`
- `teamsdevapp.vscode-ai-foundry`
- `ms-vscode.remote-server`
- `connor4312.esbuild-problem-matchers`
- `ms-vscode.vscode-speech-language-pack-pt-br`
- `ms-vscode-remote.remote-ssh`
- `github.vscode-pull-request-github`

If you're using Cursor, these extensions will not be available and should be excluded from your extension list.
