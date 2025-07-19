require 'rails_helper'

feature 'Answers deletion', %q(
  In order to manage my content
  As an authenticated user
  I want to be able to delete my own answers
) do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:answer) { create(:answer, question: question, user: user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'can delete own answer' do
      within "#answers" do
        click_on 'Delete Answer'
      end

      expect(page).to have_content 'Answer was successfully deleted'
      expect(page).not_to have_content answer.body
    end
  end
end
