# Docker Compose Development Environment

This guide explains how to use Docker Compose with your devcontainer for a full development environment with services like Ollama, databases, and more.

## Quick Start

### Option 1: Use Compose for New Projects

1. **Copy the compose devcontainer.json** to your project's `.devcontainer/` folder
2. **Open in VS Code** and reopen in container
3. **Access services** via container network names (e.g., `http://ollama:11434`)

### Option 2: Add Compose to Existing Project

1. **Update your devcontainer.json** to use the compose version
2. **Rebuild container**: `F1` → "Dev Containers: Rebuild Container"

## File Structure

```
dotfiles/
├── docker-compose.yml           # Main compose file (in your dotfiles repo)
├── devcontainer-setup.sh        # Setup script
└── README.md

your-project/
├── .devcontainer/
│   └── devcontainer.json        # Points to remote compose file
└── src/
```

## Services Included

### Always Running

- **devcontainer** - Your main development environment
- **ollama** - Local LLM API server
  - Access: `http://ollama:11434` from container
  - Web UI: `http://localhost:11434` from host

### Optional Services (Commented Out)

Uncomment in `docker-compose.yml` as needed:

- **PostgreSQL** - Relational database

  - Access: `postgres:5432` from container
  - Credentials: `marcelo/devpass`

- **Redis** - In-memory cache/database

  - Access: `redis:6379` from container

- **MongoDB** - Document database (profile: `full`)

  - Access: `mongodb:27017` from container
  - Credentials: `marcelo/devpass`

- **MinIO** - S3-compatible object storage (profile: `full`)
  - API: `minio:9000` from container
  - Console: `http://localhost:9001` from host
  - Credentials: `marcelo/devpassword123`

## Usage Examples

### Using Ollama

```python
import requests

# From inside the devcontainer
response = requests.post(
    "http://ollama:11434/api/generate",
    json={"model": "llama2", "prompt": "Hello!"}
)
```

### Using PostgreSQL

```python
import psycopg2

# From inside the devcontainer
conn = psycopg2.connect(
    host="postgres",
    database="devdb",
    user="marcelo",
    password="devpass"
)
```

### Using Redis

```python
import redis

# From inside the devcontainer
r = redis.Redis(host='redis', port=6379, db=0)
r.set('key', 'value')
```

## Commands

### Basic Usage

```bash
# Start with basic services (devcontainer + ollama)
devcontainer up

# View logs
docker compose logs

# Stop services
docker compose down
```

### GPU Support

```bash
# Windows with NVIDIA (usually works automatically)
docker compose --profile gpu up

# Linux without GPU or CPU-only
docker compose --profile cpu up

# Check if GPU is available
docker compose exec ollama nvidia-smi
```

### Managing Ollama Models

```bash
# Inside the devcontainer, install models
curl http://ollama:11434/api/pull -d '{"name":"llama2"}'

# Or use ollama CLI if installed
ollama pull llama2
ollama run llama2 "Hello world"
```

### Database Management

```bash
# Connect to PostgreSQL
docker compose exec postgres psql -U marcelo -d devdb

# Access Redis CLI
docker compose exec redis redis-cli

# MongoDB shell
docker compose exec mongodb mongosh -u marcelo -p devpass
```

## Profiles

Use profiles to control which services start:

- **Default**: `devcontainer` + `ollama`
- **Full**: All services including MongoDB and MinIO

```bash
# Start with full profile
docker compose --profile full up

# Or in devcontainer.json
"dockerComposeFile": ["docker-compose.yml"],
"runServices": ["devcontainer", "ollama", "postgres"]
```

## Troubleshooting

### Services Not Starting

```bash
# Check service status
docker compose ps

# View specific service logs
docker compose logs ollama
docker compose logs postgres
```

### Port Conflicts

If ports are already in use on your host:

```yaml
# In docker-compose.yml, change host ports
ports:
  - "11435:11434" # Use 11435 instead of 11434
```

### Data Persistence

All data is stored in Docker volumes:

- `ollama-data` - Downloaded models persist
- `postgres-data` - Database data persists
- `redis-data` - Redis data persists

### Reset Everything

```bash
# Stop and remove all containers, networks, and volumes
docker compose down -v

# Remove specific volumes
docker volume rm devcontainer_ollama-data
```

## Performance Tips

1. **Use named volumes** (already configured) for better performance
2. **Limit services** - only uncomment what you need
3. **Use profiles** - don't start heavy services unnecessarily
4. **GPU support** - uncomment GPU section in compose file if available

## Migration from Single Container

1. **Backup your work** - commit any changes
2. **Update devcontainer.json** to use compose version
3. **Update code** - change `localhost:11434` to `ollama:11434`
4. **Rebuild container**
5. **Test services** - verify everything works

Your Ollama models and other data will be preserved in Docker volumes.
