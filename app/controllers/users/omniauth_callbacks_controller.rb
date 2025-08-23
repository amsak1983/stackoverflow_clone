class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_omniauth("Google")
  end


  def failure
    redirect_to root_path, alert: "Authentication error: #{params[:message]}"
  end

  private

  def handle_omniauth(provider_name)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      if @user.email_verified?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
      else
        session[:oauth_user_id] = @user.id
        redirect_to new_user_email_confirmation_path
      end
    else
      session["devise.#{provider_name.downcase}_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: "Failed to create account"
    end
  end
end
