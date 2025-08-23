class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_omniauth("Google")
  end

  def failure
    redirect_to root_path, alert: "Authentication error: #{params[:message]}"
  end

  private

  def handle_omniauth(provider_name)
    service = OauthAuthenticationService.new(request.env["omniauth.auth"])
    result = service.authenticate

    if result[:success] && result[:user]
      @user = result[:user]

      if @user.email_verified?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
      else
        session[:oauth_user_id] = @user.id
        redirect_to new_user_email_confirmation_path
      end
    else
      error_message = result[:errors]&.first || "Failed to create account"
      session["devise.#{provider_name.downcase}_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: error_message
    end
  end
end
