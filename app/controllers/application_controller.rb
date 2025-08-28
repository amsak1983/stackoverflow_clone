class ApplicationController < ActionController::Base
  include Pundit::Authorization
  allow_browser versions: :modern

  protect_from_forgery with: :exception

  before_action :set_secure_headers

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_secure_headers
    response.headers["X-Frame-Options"] = "SAMEORIGIN"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["Content-Security-Policy"] = "default-src 'self' https://cdn.jsdelivr.net; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; img-src 'self' data:;"
  end

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    redirect_to questions_path, alert: "Record not found"
  end

  def user_not_authorized
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, alert: "У вас нет прав для выполнения этого действия") }
      format.json { head :forbidden }
      format.turbo_stream { head :forbidden }
    end
  end
end
