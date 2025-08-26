# Blog: Docker Compose for Development Environments - Beyond Single Containers

## Outline

### Introduction

- The problem with single devcontainers: mixing concerns (services + dev tools)
- Why Docker Compose is superior for development environments
- Real-world experience: WSL + Ollama connectivity issues solved

### The Evolution: From Single Container to Compose

- **Before**: Everything in one container (services installed via setup scripts)
- **After**: Isolated services with Docker Compose profiles
- **Key insight**: Services should be services, dev environment should be dev environment

### Technical Implementation Deep Dive

- Profile-based architecture (`minimal`, `ai`, `postgres`, etc.)
- Cross-platform path handling (`${HOME}${USERPROFILE}`)
- Security considerations (container network isolation)
- Volume management for data persistence

### Developer Experience Improvements

- **Simplicity**: One-line setup with curl
- **Flexibility**: Choose exactly what services you need per project
- **Maintenance**: Service updates don't break dev environment
- **Debugging**: Isolated service logs

### Production Learnings

- Why `runArgs` doesn't work with compose (and alternatives)
- Mount strategies: devcontainer.json mounts vs docker-compose volumes
- Environment variable patterns for configuration
- The importance of proper user management in containers

### Advanced Patterns

- Remote docker-compose files for easy updates
- Profile combinations for different project types
- Credential mounting strategies across platforms
- GPU vs CPU service alternatives

### Conclusion

- When to use single containers vs compose
- Migration strategy from existing setups
- Future possibilities (Kubernetes, etc.)

## Key Takeaways for Readers

1. Docker Compose profiles solve the "kitchen sink" devcontainer problem
2. Service isolation makes debugging and maintenance much easier
3. Cross-platform compatibility requires careful path handling
4. Container networks provide excellent security by default
5. Volume management is crucial for data persistence across rebuilds

## Target Audience

- Developers using VS Code devcontainers
- DevOps engineers designing development environments
- Teams looking to standardize development setups
- Anyone frustrated with complex single-container devcontainers
