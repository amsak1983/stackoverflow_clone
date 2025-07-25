module RequestHelpers
  # Helper method to sign in a user in request specs
  def sign_in_user(user = nil, scope: :user)
    user ||= create(:user)
    login_as(user, scope: scope)
    user
  end

  # Helper method to sign out a user
  def sign_out_user(scope: :user)
    logout(scope)
  end

  # Helper to set up authentication for request specs
  def setup_authentication(user = nil, scope: :user)
    user ||= create(:user)
    sign_in_user(user, scope: scope)
    user
  end

  # Helper to parse Turbo Stream responses
  def parse_turbo_stream_response
    Nokogiri::HTML5(response.body).css('turbo-stream')
  end

  # Helper to check if a Turbo Stream action was performed
  def turbo_stream_action?(action, target = nil)
    streams = parse_turbo_stream_response
    if target
      streams.any? { |s| s['action'] == action.to_s && s['target'] == target.to_s }
    else
      streams.any? { |s| s['action'] == action.to_s }
    end
  end
end

# Configure RSpec to include our helpers and set up Warden
RSpec.configure do |config|
  # Include our custom request helpers
  config.include RequestHelpers, type: :request

  # Include Devise test helpers
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Warden::Test::Helpers, type: :request

  # Include FactoryBot methods
  config.include FactoryBot::Syntax::Methods

  # Set up Warden test mode before the test suite runs
  config.before(:suite) do
    Warden.test_mode!
  end

  # Reset Warden after each test
  config.after(:each) do
    Warden.test_reset!
  end
end
