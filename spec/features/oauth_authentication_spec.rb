require 'rails_helper'

RSpec.feature 'OAuth Authentication', type: :feature do
  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  scenario 'User signs in with Google OAuth2 successfully' do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: 'google_oauth2',
      uid: '123456789',
      info: {
        email: 'test@example.com',
        name: 'Test User'
      }
    })

    visit new_user_session_path

    expect(page).to have_content('Sign in to your account')
    expect(page).to have_link('Sign in with Google')

    click_link 'Sign in with Google'

    expect(page).to have_current_path(root_path)
    expect(page).to have_content('Successfully authenticated from Google account')

    user = User.find_by(email: 'test@example.com')
    expect(user).to be_present
    expect(user.provider).to eq('google_oauth2')
    expect(user.uid).to eq('123456789')
    expect(user).to be_email_verified
  end


  scenario 'User completes email confirmation process', js: false do
    user = create(:user, :oauth_user, :unconfirmed, email: 'temp@example.com')

    user.update!(
      unconfirmed_email: 'confirmed@example.com',
      confirmation_token: 'valid_token',
      confirmation_sent_at: Time.current
    )

    visit confirm_user_email_confirmation_path(user, confirmation_token: 'valid_token')

    expect(page).to have_content('Email successfully confirmed! Welcome!')
    expect(page).to have_current_path(root_path)

    user.reload
    expect(user.email).to eq('confirmed@example.com')
    expect(user.unconfirmed_email).to be_nil
    expect(user.email_verified?).to be true
  end

  scenario 'User tries to confirm with invalid email format', js: false do
    user = create(:user, :oauth_user, :unconfirmed)

    visit confirm_user_email_confirmation_path(user, confirmation_token: 'invalid_token')

    expect(page).to have_content('Invalid or expired confirmation link')
    expect(page).to have_current_path(root_path)
  end

  scenario 'User tries to access email confirmation without OAuth session' do
    visit new_user_email_confirmation_path

    expect(page).to have_content('Session expired')
    expect(page).to have_current_path(root_path)
  end

  scenario 'User tries to confirm with expired token', js: false do
    user = create(:user,
      unconfirmed_email: 'test@example.com',
      confirmation_token: 'expired_token',
      confirmation_sent_at: 4.days.ago
    )

    visit confirm_user_email_confirmation_path(user, confirmation_token: 'expired_token')

    expect(page).to have_content('Invalid or expired confirmation link')
    expect(page).to have_current_path(root_path)
  end

  scenario 'Existing user links OAuth account' do
    existing_user = create(:user, email: 'existing@example.com')

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: 'google_oauth2',
      uid: '123456789',
      info: {
        email: 'existing@example.com',
        name: 'Existing User'
      }
    })

    visit new_user_session_path
    click_link 'Sign in with Google'

    expect(page).to have_current_path(root_path)

    existing_user.reload
    expect(existing_user.provider).to eq('google_oauth2')
    expect(existing_user.uid).to eq('123456789')
    expect(User.count).to eq(1)
  end

  scenario 'OAuth authentication failure' do
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

    visit new_user_session_path
    click_link 'Sign in with Google'

    expect(page).to have_content('Authentication error')
    expect(page).to have_current_path(root_path)
  end
end
