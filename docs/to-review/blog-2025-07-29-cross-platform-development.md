# Blog: Cross-Platform Development Environments - Windows, Linux, and Containers

## Outline

### The Cross-Platform Challenge

- **The Problem**: Different path conventions, package managers, and user models
- **Real-world scenario**: Fedora Workstation 42 + Windows 11 + WSL + Containers
- **Goal**: Same development experience everywhere

### Path Handling Strategies

- **The Pattern**: `${HOME}${USERPROFILE}` for cross-platform compatibility
- **Why it works**: Windows sets USERPROFILE, Linux/macOS set HOME
- **Container considerations**: Mount point consistency across runtimes
- **Example**: SSH key mounting that works on Docker Desktop and Podman

### User Management Across Platforms

- **Container users**: codespace vs custom users (marcelo) - the UID/GID problem
- **Permission handling**: Why bind mounts break with mismatched UIDs
- **Solution**: Stick with container defaults unless absolutely necessary
- **Lesson learned**: Fighting container user models often isn't worth it

### Package Manager Abstraction

- **Distribution detection**: Alpine (apk), Ubuntu (apt), openSUSE (dnf)
- **Container vs host**: Different approaches for different environments
- **Alias strategies**: Making commands work everywhere (doas -> sudo)
- **Environment-specific optimization**: Skip GUI config in containers

### WSL-Specific Challenges

- **Network complexity**: Container-to-host communication in WSL
- **File system performance**: NTFS vs ext4 considerations
- **Service integration**: Why Ollama in WSL was problematic
- **Solution**: Docker Compose networks eliminate host networking issues

### Container Runtime Portability

- **Docker vs Podman**: Why aliases work (docker -> podman)
- **Compose compatibility**: What works the same, what doesn't
- **Volume handling**: Named volumes vs bind mounts across runtimes
- **GPU support**: NVIDIA container runtime differences

### Development Workflow Patterns

- **Environment variables**: Consistent configuration across platforms
- **Service discovery**: Container networks vs localhost patterns
- **Credential management**: Cross-platform secure storage strategies
- **Tool installation**: mise/asdf vs platform package managers

### Testing Strategies

- **Multi-platform validation**: How to test across all target environments
- **Container testing**: Different base images for different use cases
- **Integration testing**: Ensuring services work together
- **Performance considerations**: Platform-specific optimizations

## Key Technical Patterns

### Path Resolution

```bash
# Works on Windows (USERPROFILE) and Linux/macOS (HOME)
HOST_CONFIG_PATH="${HOME}${USERPROFILE}/.config"
```

### Environment Detection

```bash
# Container, WSL, and distribution detection
detect_environment() {
    if [[ -f /.dockerenv ]] || [[ -n "${CONTAINER:-}" ]]; then
        export IN_CONTAINER="true"
    fi

    if grep -q Microsoft /proc/version 2>/dev/null; then
        export IN_WSL="true"
    fi
}
```

### Cross-Platform Service Access

```python
# Container networks eliminate cross-platform networking issues
ollama_url = "http://ollama:11434"  # Works everywhere
postgres_host = "postgres"  # No localhost complexity
```

## Lessons Learned

1. **Embrace container defaults**: Fighting user models causes more problems
2. **Network isolation wins**: Container networks solve WSL networking issues
3. **Environment variables are key**: Consistent configuration across platforms
4. **Path patterns matter**: Get the fundamentals right early
5. **Test everywhere**: Cross-platform bugs are subtle and persistent

## Target Audience

- Developers working across Windows and Linux
- Teams standardizing development environments
- DevOps engineers dealing with container portability
- Anyone struggling with WSL development complexity
