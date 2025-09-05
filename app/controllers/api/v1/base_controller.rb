module Api
  module V1
    class BaseController < ApplicationController
      include Rails.application.routes.url_helpers

      protect_from_forgery with: :null_session
      before_action :doorkeeper_authorize!
      before_action :set_default_url_options

      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "Not Found" }, status: :not_found
      end

      rescue_from Pundit::NotAuthorizedError do
        render json: { error: "Forbidden" }, status: :forbidden
      end

      private

      def set_default_url_options
        host = Rails.application.config.action_mailer.default_url_options&.[](:host)
        host ||= ENV["APP_HOST"]
        host ||= request.base_url if respond_to?(:request)
        Rails.application.routes.default_url_options[:host] = host if host
      end
    end
  end
end
