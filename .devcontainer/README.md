# 🚀 DevMagic - Docker Compose Development Environment

This devcontainer uses Docker Compose to provide a complete development environment with optional services like AI, databases, and caching.

## Quick Start

1. **Add devcontainer to your project**:

   <!-- TODO(claude): After we finish this batch of changes, lets make this into a single script, so I can put it in my site as a /devmagic.sh and call with `curl site/devmagic.sh | bash`. -->

   ```bash
   # Create .devcontainer directory and download configuration
   mkdir -p .devcontainer && curl -fsSL https://raw.githubusercontent.com/marcelocra/dotfiles/main/.devcontainer/devcontainer.json -o .devcontainer/devcontainer.json
   ```

2. **Open in VS Code**: Install the Dev Containers extension

3. **Choose your services** with environment variables:

   ```bash
   # Basic development (default)
   code myproject

   # AI project
   MCRA_COMPOSE_PROFILES=minimal,ai code myproject

   # Web app with database and cache
   MCRA_COMPOSE_PROFILES=minimal,postgres,redis code myproject
   ```

4. **Reopen in container**: `F1` → "Dev Containers: Reopen in Container"

## Available Services

Control which services start using the `MCRA_COMPOSE_PROFILES` environment variable:

- **`minimal`** (default): Just the development container
- **`ai`**: + Ollama GPU version (port 11434)
- **`ai-cpu`**: + Ollama CPU version (port 11435) 
- **`postgres`**: + PostgreSQL database (port 5432)
- **`redis`**: + Redis cache (port 6379)
- **`mongodb`**: + MongoDB database (port 27017)
- **`minio`**: + S3-compatible storage (ports 9000/9001)

## Service Access

Services communicate via container network names:

```python
# Connecting to Ollama from inside devcontainer
# TODO(claude): Question: This will only be accessible from inside the container, right? I don't want to expose it outside, to people in the same network (wifi) I'll be using. (You can remove this todo after answering.)
response = requests.post("http://ollama:11434/api/generate", ...)

# Connecting to PostgreSQL
conn = psycopg2.connect(host="postgres", database="devdb", user="marcelo", password="...")
```

## What Gets Installed

- **Base**: Universal development image with multiple language runtimes
- **User**: `codespace` user with zsh and oh-my-zsh
- **Dotfiles**: Automatically configured from [marcelocra/dotfiles](https://github.com/marcelocra/dotfiles)
- **Credentials**: SSH keys, GitHub CLI, Gemini CLI, Claude CLI automatically mounted
- **Services**: Optional AI (Ollama), databases, and storage as needed per project

## Environment Variables

Customize behavior with these environment variables:

```bash
export MCRA_COMPOSE_PROFILES="minimal,ai,postgres"  # Which services to start
export MCRA_DEV_DB_PASSWORD="YourSecurePassword!"   # Database password
export MCRA_DEVCONTAINER_USER="codespace"           # Container user
export MCRA_USE_MISE="true"                         # Enable mise tool manager
```

## Troubleshooting

<!-- TODO(claude): I'm using podman instead of docker, but I have an alias (docker->podman). Does it change anything? I'm wondering if we should use podman instead of docker in the documentation, as it is mostly focused on me, and mention that it should work with docker too. -->

### Services Not Starting
```bash
# Check what's running
docker compose ps

# View specific service logs  
docker compose logs ollama
docker compose logs postgres
```

### Port Conflicts
If ports are in use, services will fail to start. Check with:
```bash
# See which ports are in use
docker compose ps
```

### Data Persistence

<!--  -->
All data is stored in Docker volumes and persists between container rebuilds:
- Ollama models in `ollama-data` volume
- Database data in `postgres-data`, `mongodb-data`, etc.

### Complete Reset
```bash
# Stop and remove everything including data
docker compose down -v
```

### SSH Issues
- Make sure SSH keys are in `~/.ssh` on your host system
- Keys are automatically mounted to the container

### Rebuild Container
`F1` → "Dev Containers: Rebuild Container"
