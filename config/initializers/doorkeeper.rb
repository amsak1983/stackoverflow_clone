Doorkeeper.configure do
  orm :active_record

  resource_owner_authenticator do
    current_user || redirect_to(new_user_session_url)
  end

  admin_authenticator do
    current_user || redirect_to(new_user_session_url)
  end

  default_scopes :public
  optional_scopes :read, :write
  enforce_configured_scopes

  access_token_expires_in 2.hours

  use_refresh_token

  reuse_access_token

  force_ssl_in_redirect_uri !Rails.env.development?

  skip_authorization do |_resource_owner, _client|
    false
  end

  grant_flows %w[authorization_code]
end
