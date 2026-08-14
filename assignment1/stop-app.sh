#!/bin/bash
set -e

echo "Stopping app ..."

docker stop notesapp-web notesapp-db 2>/dev/null || true

echo "App stopped. Data preserved — run start-app.sh to resume."
