require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # Note: Disabled for IP-based deployment. Enable when using a domain with proper SSL certificate.
  config.force_ssl = false

  # Skip http-to-https redirect for the default health check endpoint.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Use Sidekiq for background jobs
  config.active_job.queue_adapter = :sidekiq

  # Mailer configuration
  config.action_mailer.raise_delivery_errors = true
  
  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { 
    host: ENV.fetch("APP_HOST", "90.156.228.95"),
    protocol: "http"  # Use http for IP-based deployment without SSL
  }

  # SMTP settings - configure via environment variables or rails credentials
  smtp_address = ENV["SMTP_ADDRESS"] || Rails.application.credentials.dig(:smtp, :address)
  
  if smtp_address.present?
    # SMTP is configured - use it
    config.action_mailer.perform_deliveries = true
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: smtp_address,
      port: (ENV["SMTP_PORT"] || Rails.application.credentials.dig(:smtp, :port) || 587).to_i,
      domain: ENV["SMTP_DOMAIN"] || Rails.application.credentials.dig(:smtp, :domain),
      user_name: ENV["SMTP_USERNAME"] || Rails.application.credentials.dig(:smtp, :user_name),
      password: ENV["SMTP_PASSWORD"] || Rails.application.credentials.dig(:smtp, :password),
      authentication: :plain,
      enable_starttls_auto: true
    }
  else
    # SMTP not configured - disable email delivery (dev mode)
    config.action_mailer.perform_deliveries = false
    config.action_mailer.delivery_method = :test
    Rails.logger.warn "⚠️  SMTP not configured. Email delivery is disabled. Configure SMTP_ADDRESS to enable."
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  config.hosts = [
    "90.156.228.95",     # Allow requests from server IP
    # Add your domain here when you have one:
    # "yourdomain.com",
    # /.*\.yourdomain\.com/
  ]
  
  # Skip DNS rebinding protection for the default health check endpoint.
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
