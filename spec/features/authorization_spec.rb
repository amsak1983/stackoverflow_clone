require 'rails_helper'

feature 'User authorization', %q(
  In order to maintain access control
  As an authenticated user
  I want to be able to create and delete my own questions and answers
) do
  given(:user) { create(:user) }
  given(:other_user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given(:other_question) { create(:question, user: other_user) }
  given!(:answer) { create(:answer, question: question, user: user) }
  given!(:other_answer) { create(:answer, question: question, user: other_user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      visit questions_path
    end

    scenario 'sees New Question link' do
      expect(page).to have_link 'New Question'
    end

    scenario 'can create a new question' do
      click_on 'New Question'
      fill_in 'Title', with: 'Test question'
      fill_in 'Body', with: 'Test question body'
      click_on 'Create Question'

      expect(page).to have_content 'Question was successfully created'
      expect(page).to have_content 'Test question'
    end

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

    scenario 'can add an answer to a question' do
      visit question_path(other_question)
      fill_in 'answer[body]', with: 'Test answer'
      click_on 'Post Answer'

      expect(page).to have_content 'Answer was successfully created'
      expect(page).to have_content 'Test answer'
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
    scenario 'does not see New Question link' do
      visit questions_path
      expect(page).not_to have_link 'New Question'
    end

    scenario 'cannot create a new question' do
      visit new_question_path
      expect(page).to have_content 'You need to sign in or sign up before continuing'
    end

    scenario 'cannot delete any question' do
      visit question_path(question)
      expect(page).not_to have_button 'Delete Question'
    end

    scenario 'cannot add an answer to a question' do
      visit question_path(question)
      fill_in 'answer[body]', with: 'Test answer'
      click_on 'Post Answer'

      expect(page).to have_content 'You need to sign in or sign up before continuing'
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
