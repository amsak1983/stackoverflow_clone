require 'rails_helper'

feature 'Answers creation', %q(
  In order to help community
  As an authenticated user
  I want to be able to answer questions
) do
  given(:user) { create(:user) }
  given(:other_user) { create(:user) }
  given(:question) { create(:question, user: other_user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'can add an answer to a question' do
      fill_in 'answer[body]', with: 'Test answer'
      click_on 'Post Answer'

      expect(page).to have_content 'Answer was successfully created'
      expect(page).to have_content 'Test answer'
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
