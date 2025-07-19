require 'rails_helper'

feature 'Questions deletion', %q(
  In order to manage my content
  As an authenticated user
  I want to be able to delete my own questions
) do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'can delete own question' do
      click_on 'Delete Question'
      
      expect(page).to have_content 'Question was successfully deleted'
      expect(page).not_to have_content question.title
    end
  end
end
