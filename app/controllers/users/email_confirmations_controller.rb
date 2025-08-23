class Users::EmailConfirmationsController < ApplicationController
  before_action :authenticate_oauth_user!, except: [ :confirm ]

  def new
    @user = User.find(session[:oauth_user_id])
  end

  def create
    @user = User.find(session[:oauth_user_id])

    if @user.update(email_params)
      @user.send_confirmation_instructions
      redirect_to root_path, notice: "Confirmation email sent to #{@user.unconfirmed_email}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    @user = User.find_by(id: params[:id], confirmation_token: params[:confirmation_token])

    if @user && @user.confirmation_sent_at && @user.confirmation_sent_at > 3.days.ago && @user.unconfirmed_email.present?
      @user.update_columns(
        email: @user.unconfirmed_email,
        unconfirmed_email: nil,
        confirmed_at: Time.current,
        confirmation_token: nil,
        confirmation_sent_at: nil
      )

      sign_in(@user)
      redirect_to root_path, notice: "Email successfully confirmed! Welcome!"
    else
      redirect_to root_path, alert: "Invalid or expired confirmation link"
    end
  end

  private

  def email_params
    params.require(:user).permit(:unconfirmed_email)
  end

  def authenticate_oauth_user!
    unless session[:oauth_user_id] && User.exists?(session[:oauth_user_id])
      redirect_to root_path, alert: "Session expired"
    end
  end
end
