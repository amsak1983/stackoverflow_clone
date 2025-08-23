class Users::EmailConfirmationsController < ApplicationController
  before_action :authenticate_oauth_user!, except: [ :confirm ]
  before_action :find_oauth_user, only: [ :new, :create ]

  def new
  end

  def create
    service = EmailConfirmationService.new(@user)
    result = service.send_confirmation_email(email_params[:unconfirmed_email])

    if result[:success]
      redirect_to root_path, notice: result[:message]
    else
      flash.now[:alert] = result[:errors].join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    @user = EmailConfirmationService.find_user_by_token(params[:id], params[:confirmation_token])

    unless @user
      redirect_to root_path, alert: "Invalid or expired confirmation link"
      return
    end

    service = EmailConfirmationService.new(@user)
    result = service.confirm_email(params[:confirmation_token])

    if result[:success]
      sign_in(@user)
      redirect_to root_path, notice: result[:message]
    else
      redirect_to root_path, alert: result[:errors].join(", ")
    end
  end

  private

  def email_params
    params.require(:user).permit(:unconfirmed_email)
  end

  def find_oauth_user
    @user = User.find(session[:oauth_user_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Session expired"
  end

  def authenticate_oauth_user!
    unless session[:oauth_user_id] && User.exists?(session[:oauth_user_id])
      redirect_to root_path, alert: "Session expired"
    end
  end
end
