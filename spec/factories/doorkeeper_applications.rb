FactoryBot.define do
  factory :oauth_application, class: 'Doorkeeper::Application' do
    name { 'Test OAuth App' }
    redirect_uri { 'urn:ietf:wg:oauth:2.0:oob' }
    scopes { 'public read write' }
    confidential { true }
  end
end
