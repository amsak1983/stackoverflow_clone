module FeatureHelpers
  def sign_in(user)
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    # Футер не будет перекрывать кнопку благодаря CSS в тестовой среде

    click_button 'Sign in'
  end
end
