# 🚀 DevMagic Environment

This directory contains the core configuration for the DevMagic development environment.

- `devcontainer.json`: The primary configuration file used by VS Code to define and create the development container.
- `docker-compose.yml`: Defines auxiliary services that can be run alongside the main development container.
- `Dockerfile`: A simple Dockerfile that can be used for custom builds, currently deprecated in favor of a direct `image` reference in `devcontainer.json`.

## Using Auxiliary Services (Ollama, Postgres, etc.)

This environment is designed to be modular. The main dev container starts by default, and you can bring up additional services like `ollama` or `postgres` on demand.

This process starts **after** you have already opened your project in the dev container.

### Step 1: Open a Terminal in VS Code

Open a new terminal inside VS Code (`Terminal > New Terminal`). You will be running commands from within your main dev container.

### Step 2: Start an Auxiliary Service

Your `docker-compose.yml` file is in your workspace, and because you have Docker installed in your container (via the `docker-in-docker` feature), you can use the `docker compose` command.

To start the `ollama` service, for example, run:

```bash
docker compose --profile ai up -d
```

To start `postgres`, run:

```bash
docker compose --profile postgres up -d
```

- `--profile <name>`: This flag tells Compose to look inside your `docker-compose.yml` and only start the services marked with that profile name.
- `up -d`: This creates and starts the container(s) in the background.

### Step 3: Verify the Service is Running

You now have multiple containers running side-by-side. You can verify this by running:

```bash
docker ps
```

You will see your main `devcontainer` and the new service container(s). They are on the same Docker network and can communicate with each other using their service names (e.g., `ollama`, `postgres`).

### Step 4: Connect to the Service

From inside your main dev container, you can now access the service using its name as the hostname.

- **Ollama:** `http://ollama:11434`
- **Postgres:** `postgresql://codespace:DevTime2024!coding@postgres:5432/devdb`
- **Redis:** `redis://redis:6379`

### Step 5: Stopping a Service

When you are finished, you can stop the service(s) without affecting your main dev container.

```bash
# Stop ollama
docker compose --profile ai down

# Stop postgres
docker compose --profile postgres down
```
