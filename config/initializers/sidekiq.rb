require 'sidekiq'
require 'sidekiq-cron'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }

  schedule_file = Rails.root.join('config', 'sidekiq.yml')
  if File.exist?(schedule_file)
    yaml = YAML.load_file(schedule_file)
    schedule = yaml['schedule'] || yaml[:schedule]
    Sidekiq::Cron::Job.load_from_hash(schedule) if schedule.present?
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end
