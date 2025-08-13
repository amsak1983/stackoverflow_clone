class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  protect_from_forgery with: :exception

  before_action :set_secure_headers
  before_action :set_current_user_for_cable

  private

  def set_secure_headers
    response.headers["X-Frame-Options"] = "SAMEORIGIN"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data:;"
  end

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    redirect_to questions_path, alert: "Record not found"
  end

  def set_current_user_for_cable
    cookies.encrypted[:user_id] = current_user&.id
  end
end
