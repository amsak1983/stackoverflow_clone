#!/bin/bash
# Wrapper script to run backup from host machine via Docker

set -e

CONTAINER_NAME="stackoverflow_clone-web-1"
BACKUP_HOST_DIR="/var/backups/stackoverflow_clone"

# Create backup directory on host if it doesn't exist
mkdir -p "$BACKUP_HOST_DIR"

echo "Running SQLite backup in container: $CONTAINER_NAME"

# Execute backup script inside the container
docker exec "$CONTAINER_NAME" /rails/bin/backup-sqlite.sh

# Optional: Copy backups from container to host for extra safety
# docker cp "$CONTAINER_NAME:/backups/." "$BACKUP_HOST_DIR/"

echo "Backup completed successfully"
