require 'rails_helper'

feature 'Questions creation', %q(
  In order to get answers from community
  As an authenticated user
  I want to be able to create questions
) do
  given(:user) { create(:user) }

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

    scenario 'cannot create question with invalid data' do
      click_on 'New Question'
      click_on 'Create Question'

      expect(page).to have_content "Title can't be blank"
      expect(page).to have_content "Body can't be blank"
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
  end
end
