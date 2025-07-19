require 'rails_helper'

feature 'User authorization', %q(
  In order to maintain access control
  As an authenticated user
  I want to be able to delete only my own questions and answers
) do
  given(:user) { create(:user) }
  given(:other_user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given(:other_question) { create(:question, user: other_user) }
  given!(:answer) { create(:answer, question: question, user: user) }
  given!(:other_answer) { create(:answer, question: question, user: other_user) }

  describe 'Authenticated user' do
    background { sign_in(user) }

    scenario 'can delete own question' do
      visit question_path(question)
      expect(page).to have_button 'Delete Question'

      click_on 'Delete Question'
      expect(page).to have_content 'Question was successfully deleted'
      expect(page).not_to have_content question.title
    end

    scenario 'cannot delete other users question' do
      visit question_path(other_question)
      expect(page).not_to have_button 'Delete Question'
    end

    scenario 'can delete own answer' do
      visit question_path(question)

      within "#answers" do
        expect(page).to have_content answer.body
        expect(page).to have_button 'Delete Answer', count: 1
        click_on 'Delete Answer'
      end

      expect(page).to have_content 'Answer was successfully deleted'
    end

    scenario 'cannot delete other users answer' do
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
    scenario 'cannot delete any question' do
      visit question_path(question)
      expect(page).not_to have_button 'Delete Question'
    end

    scenario 'cannot delete any answer' do
      visit question_path(question)

      within "#answers" do
        expect(page).to have_content answer.body
        expect(page).not_to have_button 'Delete Answer'
      end
    end
  end
end
