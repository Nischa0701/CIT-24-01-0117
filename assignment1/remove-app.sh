#!/bin/bash
set -e

echo "Removing app ..."

docker rm -f notesapp-web notesapp-db 2>/dev/null || true
docker rmi notesapp-web:latest 2>/dev/null || true
docker network rm notesapp-network 2>/dev/null || true
docker volume rm notesapp-db-data 2>/dev/null || true

echo "Removed app."
