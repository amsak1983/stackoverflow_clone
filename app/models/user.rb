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

  def send_confirmation_instructions
    self.confirmation_token = Devise.friendly_token
    self.confirmation_sent_at = Time.current
    save!
    UserMailer.email_confirmation(self).deliver_now
  end

  def self.from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid)

    if user
      return user
    end

    email = auth.info.email
    if email.present?
      user = find_by(email: email)
      if user
        user.update!(provider: auth.provider, uid: auth.uid)
        return user
      end
    end

    create_from_omniauth(auth)
  end

  private

  def self.create_from_omniauth(auth)
    email = auth.info.email

    if email.blank?
      create!(
        provider: auth.provider,
        uid: auth.uid,
        email: "#{auth.provider}_#{auth.uid}@temp.local",
        password: Devise.friendly_token[0, 20],
        confirmed_at: nil
      )
    else
      create!(
        provider: auth.provider,
        uid: auth.uid,
        email: email,
        password: Devise.friendly_token[0, 20],
        confirmed_at: Time.current
      )
    end
  end
end
