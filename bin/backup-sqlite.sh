#!/bin/bash
set -e

# SQLite Backup Script for Production
# Handles WAL mode, multiple databases, and retention policy

# Configuration
BACKUP_DIR="/backups"
RETENTION_DAYS=7
DATE=$(date +%Y-%m-%d-%H%M%S)
APP_NAME="stackoverflow_clone"
STORAGE_DIR="/rails/storage"

# Database files to backup
DATABASES=(
  "production.sqlite3"
  "production_cache.sqlite3"
  "production_queue.sqlite3"
  "production_cable.sqlite3"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

log_info "Starting SQLite backup at $(date)"
log_info "Backup directory: $BACKUP_DIR"

# Function to backup a single database
backup_database() {
  local db_file="$1"
  local db_path="$STORAGE_DIR/$db_file"
  
  if [ ! -f "$db_path" ]; then
    log_warn "Database file not found: $db_path (skipping)"
    return 0
  fi
  
  local backup_name="${APP_NAME}-${db_file%.sqlite3}-${DATE}.db"
  local backup_path="$BACKUP_DIR/$backup_name"
  
  log_info "Backing up $db_file..."
  
  # Checkpoint WAL file to ensure all data is in the main database file
  # This is crucial for SQLite in WAL mode
  sqlite3 "$db_path" "PRAGMA wal_checkpoint(TRUNCATE);" 2>/dev/null || {
    log_warn "WAL checkpoint failed for $db_file (database might not be in WAL mode)"
  }
  
  # Create backup using SQLite's backup command (safer than cp)
  sqlite3 "$db_path" ".backup '$backup_path'" || {
    log_error "Failed to backup $db_file"
    return 1
  }
  
  # Verify backup integrity
  sqlite3 "$backup_path" "PRAGMA integrity_check;" > /dev/null 2>&1 || {
    log_error "Backup integrity check failed for $backup_name"
    rm -f "$backup_path"
    return 1
  }
  
  # Compress backup to save space
  gzip "$backup_path" || {
    log_error "Failed to compress backup $backup_name"
    return 1
  }
  
  local compressed_size=$(du -h "${backup_path}.gz" | cut -f1)
  log_info "✓ Backup created: ${backup_name}.gz (${compressed_size})"
}

# Backup all databases
BACKUP_SUCCESS=true
for db in "${DATABASES[@]}"; do
  if ! backup_database "$db"; then
    BACKUP_SUCCESS=false
  fi
done

# Clean up old backups (keep last N days)
log_info "Cleaning up backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -name "${APP_NAME}-*.db.gz" -type f -mtime +$RETENTION_DAYS -delete

# Count remaining backups
BACKUP_COUNT=$(find "$BACKUP_DIR" -name "${APP_NAME}-*.db.gz" -type f | wc -l)
log_info "Total backups in storage: $BACKUP_COUNT"

# Calculate total backup size
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
log_info "Total backup size: $TOTAL_SIZE"

if [ "$BACKUP_SUCCESS" = true ]; then
  log_info "✓ Backup completed successfully at $(date)"
  exit 0
else
  log_error "✗ Backup completed with errors at $(date)"
  exit 1
fi
