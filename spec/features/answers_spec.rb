require 'rails_helper'

RSpec.describe 'Answers', type: :feature do
  describe 'User interaction with answers' do
    let(:user) { create(:user) }
    let(:question) { create(:question, user: user) }

    scenario 'User adds an answer to the question' do
      sign_in(user)
      visit question_path(question)

      # Expect to see the form for new answer
      expect(page).to have_field('answer[body]')

      # Fill in the answer form
      fill_in 'answer[body]', with: 'This is my test answer to the question'

      # Submit the form
      click_button 'Post Answer'

      # Expect to see the answer on the page
      expect(page).to have_content('Answer was successfully created')
      expect(page).to have_content('This is my test answer to the question')
    end

    scenario 'User cannot add an invalid answer' do
      sign_in(user)
      visit question_path(question)

      # Submit an empty answer
      click_button 'Post Answer'

      # Expect to see validation errors
      expect(page).to have_content("Body can't be blank")
    end
  end
end
