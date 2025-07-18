require 'rails_helper'

RSpec.describe 'Authentication', type: :feature do
  describe 'User registration' do
    scenario 'User can register with valid data' do
      visit new_user_registration_path

      fill_in 'Email', with: 'test@example.com'
      fill_in 'Password', with: 'password123'
      fill_in 'Password confirmation', with: 'password123'

      expect { click_button 'Sign up' }.to change(User, :count).by(1)

      expect(page).to have_content('Welcome! You have signed up successfully')
      expect(page).to have_content('Sign out')
    end

    scenario 'User cannot register with invalid data' do
      visit new_user_registration_path

      click_button 'Sign up'

      expect(page).to have_content("Email can't be blank")
      expect(page).to have_content("Password can't be blank")
      expect(User.count).to eq(0)
    end
  end

  describe 'User login and logout' do
    let!(:user) { create(:user, email: 'user@example.com', password: 'password123') }

    scenario 'User can log in with valid credentials' do
      visit new_user_session_path

      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'password123'

      click_button 'Log in'

      expect(page).to have_content('Signed in successfully')
      expect(page).to have_content('Sign out')
    end

    scenario 'User cannot log in with invalid credentials' do
      visit new_user_session_path

      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'wrongpassword'

      click_button 'Log in'

      expect(page).to have_content('Invalid Email or password')
      expect(page).not_to have_content('Sign out')
    end

    scenario 'User can log out' do
      sign_in user
      visit root_path

      click_link 'Sign out'

      expect(page).to have_content('Signed out successfully')
      expect(page).to have_content('Log in')
    end
  end
end
