require "sidekiq"
require "sidekiq-cron"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }

  # Prometheus instrumentation for Sidekiq server
  unless Rails.env.test?
    require "prometheus_exporter/instrumentation"

    # Setup Prometheus client to connect to exporter
    # Use 127.0.0.1 instead of localhost to avoid DNS resolution issues
    PrometheusExporter::Client.default = PrometheusExporter::Client.new(
      host: "127.0.0.1",
      port: 9394
    )

    # Add Sidekiq middleware for job metrics
    config.server_middleware do |chain|
      chain.add PrometheusExporter::Instrumentation::Sidekiq
    end

    # Track failed jobs
    config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler

    # Track Sidekiq process and queue stats
    PrometheusExporter::Instrumentation::SidekiqProcess.start
    PrometheusExporter::Instrumentation::SidekiqQueue.start
  end

  schedule_file = Rails.root.join("config", "sidekiq.yml")
  if File.exist?(schedule_file)
    yaml = YAML.load_file(schedule_file)
    schedule = yaml["schedule"] || yaml[:schedule]
    Sidekiq::Cron::Job.load_from_hash(schedule) if schedule.present?
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
end
