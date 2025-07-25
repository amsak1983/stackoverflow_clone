require 'rails_helper'

feature 'Questions deletion', %q(
  In order to manage my content
  As an authenticated user
  I want to be able to delete my own questions
) do
  given(:user) { create(:user) }
  given(:other_user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given(:other_question) { create(:question, user: other_user) }

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

    scenario 'cannot see delete button for other user question' do
      visit question_path(other_question)
      
      expect(page).not_to have_button 'Delete Question'
    end
  end
end
