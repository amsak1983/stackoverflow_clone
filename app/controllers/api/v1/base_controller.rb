module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization
      include Rails.application.routes.url_helpers

      before_action :doorkeeper_authorize!
      before_action :set_default_url_options

      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "Not Found" }, status: :not_found
      end

      rescue_from Pundit::NotAuthorizedError do
        render json: { error: "Forbidden" }, status: :forbidden
      end

      private

      def current_user
        @current_user ||= User.find(doorkeeper_token&.resource_owner_id) if doorkeeper_token
      end

      def set_default_url_options
        host = Rails.application.config.action_mailer.default_url_options&.[](:host)
        host ||= ENV["APP_HOST"]
        host ||= request.base_url if respond_to?(:request)
        Rails.application.routes.default_url_options[:host] = host if host
      end
    end
  end
end
