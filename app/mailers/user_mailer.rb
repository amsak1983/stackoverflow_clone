class UserMailer < ApplicationMailer
  default from: "noreply@stackoverflow-clone.com"

  def email_confirmation(user)
    @user = user
    @confirmation_url = confirm_user_email_confirmation_url(@user, confirmation_token: @user.confirmation_token)

    mail(
      to: @user.unconfirmed_email,
      subject: "Confirm your email address"
    )
  end
end
