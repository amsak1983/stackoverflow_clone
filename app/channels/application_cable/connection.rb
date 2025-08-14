module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags "ActionCable", "User #{current_user&.id || 'Anonymous'}"
    end

    private

    def find_verified_user
      # Allow anonymous connections for public channels
      user = env["warden"]&.user
      logger.info "ActionCable connection attempt by user: #{user&.id || 'Anonymous'}"
      user
    end
  end
end
