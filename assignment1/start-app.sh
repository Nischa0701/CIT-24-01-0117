#!/bin/bash
set -e

echo "Running app ..."

# Postgres: start existing container, or create it if it doesn't exist
if [ "$(docker ps -aq -f name=^notesapp-db$)" ]; then
    docker start notesapp-db
else
    docker run -d \
        --name notesapp-db \
        --network notesapp-network \
        --restart unless-stopped \
        -e POSTGRES_DB=notesdb \
        -e POSTGRES_USER=notesuser \
        -e POSTGRES_PASSWORD=notespassword \
        -v notesapp-db-data:/var/lib/postgresql/data \
        postgres:16-alpine
fi

# Flask: start existing container, or create it if it doesn't exist
if [ "$(docker ps -aq -f name=^notesapp-web$)" ]; then
    docker start notesapp-web
else
    docker run -d \
        --name notesapp-web \
        --network notesapp-network \
        --restart unless-stopped \
        -p 5000:5000 \
        -e DB_HOST=notesapp-db \
        -e DB_NAME=notesdb \
        -e DB_USER=notesuser \
        -e DB_PASSWORD=notespassword \
        notesapp-web:latest
fi

echo "The app is available at http://localhost:5000"
