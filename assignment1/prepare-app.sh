#!/bin/bash
set -e

echo "Preparing app ..."

# Build the custom Flask image
docker build -t notesapp-web:latest ./app

# Create the custom network (if it doesn't already exist)
if ! docker network ls --format '{{.Name}}' | grep -q '^notesapp-network$'; then
    docker network create notesapp-network
fi

# Create the named volume for Postgres data (if it doesn't already exist)
if ! docker volume ls --format '{{.Name}}' | grep -q '^notesapp-db-data$'; then
    docker volume create notesapp-db-data
fi

echo "Preparation complete."
