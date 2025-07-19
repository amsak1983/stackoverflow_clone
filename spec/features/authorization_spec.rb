require 'rails_helper'

feature 'User authorization', %q(
  In order to maintain access control
  As a user
  I want to see delete buttons only for my own content
) do
  given(:user) { create(:user) }
  given(:other_user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given(:other_question) { create(:question, user: other_user) }
  given!(:answer) { create(:answer, question: question, user: user) }
  given!(:other_answer) { create(:answer, question: question, user: other_user) }

  describe 'Authenticated user' do
    background { sign_in(user) }

    scenario 'sees delete button for own question' do
      visit question_path(question)
      expect(page).to have_button 'Delete Question'
    end

    scenario 'does not see delete button for other users question' do
      visit question_path(other_question)
      expect(page).not_to have_button 'Delete Question'
    end

    scenario 'sees delete button for own answer' do
      visit question_path(question)

      within "#answers" do
        expect(page).to have_content answer.body
        expect(page).to have_button 'Delete Answer', count: 1
      end
    end

    scenario 'does not see delete button for other users answer' do
      visit question_path(question)

      within "#answers" do
        expect(page).to have_content other_answer.body
        within all('.answer').last do
          expect(page).not_to have_button 'Delete Answer'
        end
      end
    end
  end

  describe 'Unauthenticated user' do
    scenario 'does not see delete button for any question' do
      visit question_path(question)
      expect(page).not_to have_button 'Delete Question'
    end

    scenario 'does not see delete button for any answer' do
      visit question_path(question)

      within "#answers" do
        expect(page).to have_content answer.body
        expect(page).not_to have_button 'Delete Answer'
      end
    end
  end
end
