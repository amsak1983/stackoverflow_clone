module ApiHelpers
  def bearer_headers(token)
    {
      'Authorization' => "Bearer #{token.token}",
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  def create_access_token_for(user, scopes: 'public read write', expires_in: 2.hours)
    application = Doorkeeper::Application.first || create(:oauth_application)
    Doorkeeper::AccessToken.create!(
      application: application,
      resource_owner_id: user.id,
      scopes: scopes,
      expires_in: expires_in.to_i
    )
  end
end
