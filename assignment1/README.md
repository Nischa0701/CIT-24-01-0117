# Notes App — Dockerized Web Application

**Course:** CCS3308 – Virtualization and Containers                   
**Assignment:** Assignment 1


**Access the app at:** http://localhost:5000 (after running `start-app.sh`)

## Application Description

A simple notes-taking web application. Users can add short text notes through a web browser and delete them. Notes are stored in a PostgreSQL database, so they persist even if the application container is stopped, restarted, or recreated.

## Deployment Requirements

- Docker (tested on version 24+)
- Docker Compose (optional — only needed if using `docker-compose.yaml` instead of the shell scripts)
- Bash shell (Linux/macOS/WSL)

## Architecture

| Service | Image | Port | Role |
|---|---|---|---|
| web | Custom (built from `app/Dockerfile`, Python 3.12 + Flask) | 5000 (exposed to host) | Serves the web UI, handles add/delete note requests |
| db | postgres:16-alpine (official image) | 5432 (internal only) | Stores notes persistently |

## Network and Volume Details

- **Network:** `notesapp-network` — a custom Docker bridge network created by `prepare-app.sh`. Both containers join this network, allowing the `web` container to reach the `db` container by its container name (`notesapp-db`) instead of an IP address.
- **Volume:** `notesapp-db-data` — a named Docker volume mounted at `/var/lib/postgresql/data` inside the `db` container. This is where PostgreSQL stores all its data files, so notes survive container stop/start/removal-and-recreation as long as the volume itself isn't deleted (only `remove-app.sh` deletes it).

## Container Configuration

- **notesapp-web**
  - Built from `app/Dockerfile` (Python 3.12-slim base image)
  - Environment variables: `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` (used to connect to Postgres)
  - Restart policy: `unless-stopped`
  - Publishes port `5000` to the host

- **notesapp-db**
  - Official `postgres:16-alpine` image
  - Environment variables: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
  - Restart policy: `unless-stopped`
  - Port `5432` is not published to the host — only reachable from the `web` container over the internal network

## Container List

| Container Name | Role |
|---|---|
| notesapp-web | Flask web application (frontend + logic) |
| notesapp-db | PostgreSQL database (persistent storage) |

## Instructions

### Prepare (build image, create network and volume)
```bash
./prepare-app.sh
```

### Run (start both containers)
```bash
./start-app.sh
```

### Access the application
Open a browser and go to:http://localhost:5000/


### Pause (stop containers, keep data)
```bash
./stop-app.sh
```

### Resume after pausing
```bash
./start-app.sh
```

### Delete everything (containers, image, network, volume)
```bash
./remove-app.sh
```

### Alternative: using Docker Compose
```bash
docker compose up -d --build   # start
docker compose stop            # pause
docker compose start           # resume
docker compose down --volumes  # remove everything including data
```

## Example Workflow

```bash
# Create application resources
./prepare-app.sh
Preparing app ...

# Run the application
./start-app.sh
Running app ...
The app is available at http://localhost:5000

# Open a web browser and interact with the application

# Pause the application
./stop-app.sh
Stopping app ...

# Delete all application resources
./remove-app.sh
Removed app.
```

## Notes on Originality

This application and all scripts were written specifically for this assignment. The architecture (Flask + PostgreSQL with a custom bridge network and named volume) follows standard Docker best practices covered in the course lectures.
