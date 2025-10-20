# encoding: utf-8

##
# Backup Configuration for StackOverflow Clone
# Generated for Backup v5.x
##

# Load Rails environment for access to Rails.root and other constants
require File.expand_path("../../config/environment", __FILE__)

##
# Define a Backup Model
##
Backup::Model.new(:stackoverflow_clone_db, "SQLite Database Backup") do
  ##
  # Split [Splitter]
  #
  # Split the backup file in to chunks of 250 megabytes
  # if the backup file size exceeds 250 megabytes
  #
  split_into_chunks_of 250

  ##
  # SQLite Database [Database]
  #
  # Backup all production SQLite databases
  #
  database SQLite do |db|
    db.path = Rails.root.join("storage", "production.sqlite3").to_s
    db.sqlitedump_utility = "/usr/bin/sqlite3"
  end

  # Backup cache database
  database SQLite do |db|
    db.path = Rails.root.join("storage", "production_cache.sqlite3").to_s
    db.sqlitedump_utility = "/usr/bin/sqlite3"
  end

  # Backup queue database
  database SQLite do |db|
    db.path = Rails.root.join("storage", "production_queue.sqlite3").to_s
    db.sqlitedump_utility = "/usr/bin/sqlite3"
  end

  # Backup cable database
  database SQLite do |db|
    db.path = Rails.root.join("storage", "production_cable.sqlite3").to_s
    db.sqlitedump_utility = "/usr/bin/sqlite3"
  end

  ##
  # Local (Copy) [Storage]
  #
  # Store backups locally in the /backups directory
  #
  store_with Local do |local|
    local.path = "/backups"
    local.keep = 7  # Keep last 7 backups
  end

  ##
  # Gzip [Compressor]
  #
  # Compress the backup using gzip
  #
  compress_with Gzip do |compression|
    compression.level = 6  # Compression level (1-9, default: 6)
  end

  ##
  # Mail [Notifier]
  #
  # Send email notification on backup completion
  # Uncomment and configure if you want email notifications
  #
  # notify_by Mail do |mail|
  #   mail.on_success = false
  #   mail.on_warning = true
  #   mail.on_failure = true
  #
  #   mail.from                 = ENV["MAILER_FROM_EMAIL"]
  #   mail.to                   = "admin@example.com"
  #   mail.address              = ENV["SMTP_ADDRESS"]
  #   mail.port                 = ENV["SMTP_PORT"]
  #   mail.domain               = ENV["SMTP_DOMAIN"]
  #   mail.user_name            = ENV["SMTP_USERNAME"]
  #   mail.password             = ENV["SMTP_PASSWORD"]
  #   mail.authentication       = "plain"
  #   mail.encryption           = :starttls
  # end
end

##
# Optional: Amazon S3 Storage
# Uncomment to enable S3 backup storage
##
# Backup::Model.new(:stackoverflow_clone_db_s3, "SQLite Database Backup to S3") do
#   # ... same database configuration as above ...
#
#   store_with S3 do |s3|
#     s3.access_key_id     = ENV["AWS_ACCESS_KEY_ID"]
#     s3.secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
#     s3.region            = ENV.fetch("AWS_REGION", "us-east-1")
#     s3.bucket            = ENV.fetch("S3_BACKUP_BUCKET", "stackoverflow-clone-backups")
#     s3.path              = "database_backups"
#     s3.keep              = 30  # Keep last 30 backups on S3
#   end
#
#   compress_with Gzip
# end
