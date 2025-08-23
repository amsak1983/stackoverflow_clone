class EmailConfirmationService
  CONFIRMATION_TOKEN_EXPIRY = 3.days.freeze

  class InvalidTokenError < StandardError; end
  class ExpiredTokenError < StandardError; end
  class InvalidEmailError < StandardError; end

  def initialize(user)
    @user = user
  end

  def send_confirmation_email(email)
    raise InvalidEmailError, "Invalid email format" unless valid_email?(email)

    @user.transaction do
      @user.update!(
        unconfirmed_email: email,
        confirmation_token: generate_token,
        confirmation_sent_at: Time.current
      )

      UserMailer.email_confirmation(@user).deliver_now
    end

    { success: true, message: "Confirmation email sent to #{email}" }
  rescue StandardError => e
    Rails.logger.error "Failed to send confirmation email: #{e.message}"
    { success: false, errors: [ e.message ] }
  end

  def confirm_email(token)
    validate_confirmation_token!(token)

    @user.transaction do
      confirmed_email = @user.unconfirmed_email
      @user.update_columns(
        email: confirmed_email,
        unconfirmed_email: nil,
        confirmed_at: Time.current,
        confirmation_token: nil,
        confirmation_sent_at: nil
      )
    end

    { success: true, message: "Email successfully confirmed! Welcome!" }
  rescue InvalidTokenError, ExpiredTokenError => e
    { success: false, errors: [ e.message ] }
  rescue StandardError => e
    Rails.logger.error "Failed to confirm email: #{e.message}"
    { success: false, errors: [ "Confirmation failed" ] }
  end

  def self.find_user_by_token(user_id, token)
    User.find_by(id: user_id, confirmation_token: token)
  end

  private

  attr_reader :user

  def valid_email?(email)
    email.present? && email.match?(URI::MailTo::EMAIL_REGEXP)
  end

  def generate_token
    Devise.friendly_token
  end

  def validate_confirmation_token!(token)
    raise InvalidTokenError, "Invalid or expired confirmation link" if @user.confirmation_token != token
    raise InvalidTokenError, "Invalid or expired confirmation link" if @user.unconfirmed_email.blank?

    if token_expired?
      raise ExpiredTokenError, "Invalid or expired confirmation link"
    end
  end

  def token_expired?
    @user.confirmation_sent_at.blank? ||
    @user.confirmation_sent_at < CONFIRMATION_TOKEN_EXPIRY.ago
  end
end
