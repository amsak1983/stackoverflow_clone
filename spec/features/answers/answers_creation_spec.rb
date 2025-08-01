require 'rails_helper'

feature 'Answers creation', %q(
  In order to ensure data quality
  As a system
  I want to validate answer creation and control access
) do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'cannot create answer with invalid data' do
      click_on 'Post Answer'

      expect(page).to have_content "Body can't be blank"
    end
  end

  describe 'Unauthenticated user' do
    scenario 'cannot add an answer to a question' do
      visit question_path(question)
      fill_in 'answer[body]', with: 'Test answer'
      click_on 'Post Answer'

      expect(page).to have_content 'You need to sign in or sign up before continuing'
    end
  end
end
