class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :created_rewards, class_name: "Reward", dependent: :destroy
  has_many :received_rewards, class_name: "Reward", foreign_key: "recipient_id", dependent: :nullify

  validates :email, presence: true, uniqueness: true, allow_blank: false
  validates :unconfirmed_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :provider, :uid, presence: true, if: :oauth_user?

  # Отключаем автоматическую отправку confirmation instructions для OAuth пользователей с временным email
  def send_on_create_confirmation_instructions
    return if oauth_user? && email.include?("@temp.local")
    super
  end

  def name
    email.split("@").first&.capitalize || "User"
  end

  def author_of?(record)
    record.user_id == id
  end

  def oauth_user?
    provider.present? && uid.present?
  end

  def email_verified?
    confirmed_at.present?
  end

  def send_confirmation_instructions(email = nil)
    if email
      service = EmailConfirmationService.new(self)
      service.send_confirmation_email(email)
    else
      super()
    end
  end

  def self.from_omniauth(auth)
    service = OauthAuthenticationService.new(auth)
    result = service.authenticate
    result[:user]
  end
end
