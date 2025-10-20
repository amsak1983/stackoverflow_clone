# frozen_string_literal: true

# Prometheus metrics configuration
# Skip during assets:precompile and in test environment
unless Rails.env.test? || ENV["SECRET_KEY_BASE_DUMMY"]
  require "prometheus_exporter/middleware"
  require "prometheus_exporter/instrumentation"

  # Start Prometheus exporter server on port 9394
  # This runs in a separate process and collects metrics
  PrometheusExporter::Client.default = PrometheusExporter::Client.new(
    host: "localhost",
    port: 9394
  )

  # Instrument Rails web requests
  PrometheusExporter::Instrumentation::Process.start(type: "web")

  # Instrument ActiveRecord queries
  PrometheusExporter::Instrumentation::ActiveRecord.start(
    custom_labels: { type: "web" },
    config_labels: [ :database, :host ]
  )

  # Instrument Sidekiq jobs
  if defined?(Sidekiq)
    PrometheusExporter::Instrumentation::Sidekiq.start
  end
end
