class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :omniauthable, omniauth_providers: [ :google_oauth2 ]

  include Elasticsearch::Model
  # Callbacks disabled to prevent 500 errors if Elasticsearch is unavailable
  # Use User.__elasticsearch__.import for manual indexing if needed
  # include Elasticsearch::Model::Callbacks

  settings index: { number_of_shards: 1, number_of_replicas: 0 } do
    mappings dynamic: false do
      indexes :email, type: :text
      indexes :name,  type: :text
    end
  end

  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :created_rewards, class_name: "Reward", dependent: :destroy
  has_many :received_rewards, class_name: "Reward", foreign_key: "recipient_id", dependent: :nullify
  has_many :subscriptions, dependent: :destroy
  has_many :subscribed_questions, through: :subscriptions, source: :question

  validates :email, presence: true, uniqueness: true, allow_blank: false
  validates :unconfirmed_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :provider, :uid, presence: true, if: :oauth_user?

  def as_indexed_json(_options = {})
    {
      email: email,
      name: name
    }
  end

  def self.search_simple(query)
    return none if query.blank?

    __elasticsearch__.search(
      query: {
        multi_match: {
          query: query,
          fields: %w[email name]
        }
      }
    )
  end

  def send_on_create_confirmation_instructions
    return if oauth_user? && email.include?("@temp.local")
    return if confirmed?
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
