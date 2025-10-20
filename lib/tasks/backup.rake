namespace :backup do
  desc "Run database backup using Backup gem"
  task run: :environment do
    puts "Starting database backup..."
    config_file = Rails.root.join("config", "backup.rb").to_s
    system("backup", "perform", "--trigger", "stackoverflow_clone_db", "--config-file", config_file)
    puts "Backup completed!"
  end

  desc "List all available backups"
  task list: :environment do
    backup_dir = "/backups"
    if Dir.exist?(backup_dir)
      puts "Available backups in #{backup_dir}:"
      Dir.glob("#{backup_dir}/**/*.tar*").sort.reverse.each do |file|
        size = File.size(file).to_f / 1024 / 1024
        mtime = File.mtime(file)
        puts "  #{File.basename(file)} (#{size.round(2)} MB) - #{mtime.strftime('%Y-%m-%d %H:%M:%S')}"
      end
    else
      puts "Backup directory not found: #{backup_dir}"
    end
  end

  desc "Clean old backups (keeps last 7)"
  task clean: :environment do
    backup_dir = "/backups"
    if Dir.exist?(backup_dir)
      backups = Dir.glob("#{backup_dir}/**/*.tar*").sort
      keep_count = 7

      if backups.size > keep_count
        to_delete = backups[0..-(keep_count + 1)]
        puts "Deleting #{to_delete.size} old backup(s)..."
        to_delete.each do |file|
          puts "  Deleting: #{File.basename(file)}"
          File.delete(file)
        end
        puts "Cleanup completed!"
      else
        puts "No old backups to clean (found #{backups.size} backup(s), keeping #{keep_count})"
      end
    else
      puts "Backup directory not found: #{backup_dir}"
    end
  end
end
