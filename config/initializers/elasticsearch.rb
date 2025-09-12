# Configure Elasticsearch client for Rails
# In Elasticsearch 8+, security (TLS + auth) is enabled by default. In development,
# point the client to your secured HTTPS endpoint via ENV:
#   export ELASTICSEARCH_URL="https://elastic:password@localhost:9200"
# If you don't have a local CA certificate handy, you can disable SSL verification in development only.

require "elasticsearch/model"

Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: ENV.fetch("ELASTICSEARCH_URL", "http://127.0.0.1:9200"),
  transport_options: {
    request: { timeout: 5, open_timeout: 2 }
  },
  ssl: Rails.env.development? ? { verify: false } : {}
)

# Optional: log to Rails logger in development
if Rails.env.development?
  Elasticsearch::Model.client.transport.logger = Logger.new(STDOUT)
end
