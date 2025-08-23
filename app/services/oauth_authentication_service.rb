class OauthAuthenticationService
  class AuthenticationError < StandardError; end
  class UserCreationError < StandardError; end

  def initialize(auth_hash)
    @auth_hash = auth_hash
    @provider = auth_hash.provider
    @uid = auth_hash.uid
    @email = auth_hash.info.email
  end

  def authenticate
    user = find_or_create_user
    
    if user.persisted?
      { user: user, success: true }
    else
      { user: nil, success: false, errors: user.errors.full_messages }
    end
  rescue StandardError => e
    Rails.logger.error "OAuth authentication failed: #{e.message}"
    { user: nil, success: false, errors: [e.message] }
  end

  private

  attr_reader :auth_hash, :provider, :uid, :email

  def find_or_create_user
    User.transaction do
      find_existing_user || create_new_user
    end
  end

  def find_existing_user
    user = User.find_by(provider: provider, uid: uid)
    return user if user

    return nil if email.blank?
    
    user = User.find_by(email: email)
    if user
      user.update!(provider: provider, uid: uid)
      user
    end
  end

  def create_new_user
    if email.present?
      create_confirmed_user
    else
      create_unconfirmed_user
    end
  end

  def create_confirmed_user
    User.create!(
      provider: provider,
      uid: uid,
      email: email,
      password: generate_secure_password,
      confirmed_at: Time.current
    )
  end

  def create_unconfirmed_user
    User.create!(
      provider: provider,
      uid: uid,
      email: generate_temp_email,
      password: generate_secure_password,
      confirmed_at: nil
    )
  end

  def generate_temp_email
    "#{provider}_#{uid}@temp.local"
  end

  def generate_secure_password
    Devise.friendly_token[0, 20]
  end
end
