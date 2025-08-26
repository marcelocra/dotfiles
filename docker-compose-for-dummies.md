# Docker Compose for Dummies

Everything you need to know to effectively use Docker Compose.

## Core Concepts

### What is Docker Compose?

Docker Compose runs **multiple containers** as a **single application**. Instead of running containers individually, you define them all in one `docker-compose.yml` file.

### Key Difference from Single Containers

```bash
# Single container (what you had before)
docker run -p 8080:8080 myapp

# Compose (what you have now) 
docker compose up  # Starts ALL defined services
```

## Services vs Containers

**Service** = A blueprint for containers. **Container** = Running instance.

```yaml
services:
  web:      # Service name
    image: nginx
  database: # Another service
    image: postgres
```

Running `docker compose up` creates:
- 1 container from `web` service  
- 1 container from `database` service
- Both can talk to each other by service name

## Profiles: The Magic of Selective Services

**Profiles control which services start:**

```yaml
services:
  devcontainer:
    profiles: [minimal]    # Always starts with minimal
  
  ollama:  
    profiles: [ai]         # Only starts with ai profile
    
  postgres:
    profiles: [postgres]   # Only starts with postgres profile
```

**Usage:**
```bash
# Just devcontainer
COMPOSE_PROFILES=minimal docker compose up

# Devcontainer + AI  
COMPOSE_PROFILES=minimal,ai docker compose up

# Devcontainer + Database + Cache
COMPOSE_PROFILES=minimal,postgres,redis docker compose up
```

## Why Two Ollama Services?

<!-- TODO(claude): Update the comments in the docker-compose file to remove the 'fallback' comment. Mention that it is an alternative. Questions: [1] will the gpu one simply fail in a system without gpus? [2] I imagine that if I have non-nvidia gpus (say, AMD), I will need  a different service, right? No need to implement it now, I just want to understand. My gpus are nvidia. [3] So one will never run them at the same time, right? If so, why use different ports? -->
**You were right to be confused!** They're **alternatives**, not fallbacks:

- `ollama` (profile: `ai`) - GPU version on port 11434
- `ollama-cpu` (profile: `ai-cpu`) - CPU version on port 11435

**Choose one:**
```bash
# Use GPU version (if you have NVIDIA)
COMPOSE_PROFILES=minimal,ai code myproject

# Use CPU version (if no GPU) 
COMPOSE_PROFILES=minimal,ai-cpu code myproject
```

Docker Compose doesn't have "automatic fallbacks" - you explicitly choose which services to run.

## Networks: Container Communication

```yaml
networks:
  dev-network:    # Custom network name
```

**All services in the same network can talk to each other by service name:**

```python
# Inside devcontainer, connecting to postgres service
conn = psycopg2.connect(host="postgres", port=5432)  # Not localhost!

# Connecting to ollama service  
response = requests.get("http://ollama:11434/api/health")
```

## Volumes: The Confusing Part

**Yes, you need BOTH volume declarations:**

### In Services (Where to Mount):
```yaml
services:
  postgres:
    volumes:
      - postgres-data:/var/lib/postgresql/data  # Mount named volume here
```

### In Top-Level Volumes (What to Create):
```yaml
volumes:
  postgres-data:  # Create this named volume
```

**Think of it as:**
1. Top-level `volumes:` = "Create storage called postgres-data"
2. Service `volumes:` = "Mount that storage at this path inside container"

## Environment Variables 

**Two types:**

### 1. Container Environment (Inside container):
```yaml
services:
  devcontainer:
    environment:
      - MCRA_USE_MISE=true      # Set inside container
```

### 2. Host Environment (Controls compose):
```bash
# Set on host before running compose
export COMPOSE_PROFILES=minimal,ai
docker compose up
```

<!-- TODO(claude): So if I set MCRA_USE_MISE to false before calling `docker compose up`, it will override the `true` defined in the compose file, right? -->
**Yes, MCRA_USE_MISE reads from your shell environment automatically!**

## Common Commands

```bash
# Start services (with profiles)
COMPOSE_PROFILES=minimal,ai docker compose up

# Start in background
COMPOSE_PROFILES=minimal,ai docker compose up -d

# See what's running
docker compose ps

# View logs
docker compose logs ollama
docker compose logs --follow postgres

# Stop everything
docker compose down

# Stop and remove volumes (nuclear option)
docker compose down -v

# Execute command in running container
docker compose exec devcontainer bash
docker compose exec postgres psql -U marcelo -d devdb
```

## Your Setup Summary

**Profile Structure:**
- `minimal`: Just devcontainer (default)
- `ai`: + Ollama GPU version  
- `ai-cpu`: + Ollama CPU version
- `postgres`: + PostgreSQL database
- `redis`: + Redis cache
- `mongodb`: + MongoDB database  
- `minio`: + S3-compatible storage

<!-- TODO(claude): The .devcontainer/README.md should be updated with something like this and the 'Common Commands' mentioned above. -->
**Usage Examples:**
```bash
# Basic development
COMPOSE_PROFILES=minimal code myproject

# AI project with database
COMPOSE_PROFILES=minimal,ai,postgres code myproject  

# Full web application stack
COMPOSE_PROFILES=minimal,ai,postgres,redis code myproject
```

<!-- TODO(claude): Make a TL;DR section at the top with these and whatever else are the key points that I should never forget. It should be a small, summarized, section, like this one. -->
**Key Points:**
- Services in same compose file can talk via service names (`ollama:11434`, not `localhost:11434`)
- Profiles let you pick which services to run per project
- Volumes persist data between container restarts
- Environment variables control both compose behavior and container settings

That's really all you need to know! The rest is just variations on these concepts.