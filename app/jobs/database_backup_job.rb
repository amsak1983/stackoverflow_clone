class DatabaseBackupJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting database backup job..."
    
    config_file = Rails.root.join("config", "backup.rb")
    
    unless File.exist?(config_file)
      Rails.logger.error "Backup configuration file not found: #{config_file}"
      raise "Backup configuration file not found"
    end

    # Run backup command
    command = "backup perform --trigger stackoverflow_clone_db --config-file #{config_file}"
    
    result = system(command)
    
    if result
      Rails.logger.info "Database backup completed successfully"
    else
      Rails.logger.error "Database backup failed with exit code: #{$?.exitstatus}"
      raise "Database backup failed"
    end
  rescue => e
    Rails.logger.error "Database backup job error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
end
