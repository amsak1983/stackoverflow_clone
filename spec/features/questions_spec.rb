require 'rails_helper'

RSpec.describe 'Questions', type: :feature do
  describe 'User interacts with questions' do
    let(:user) { create(:user) }

    scenario 'User views the list of questions' do
      # Create some test questions
      questions = create_list(:question, 3)

      # Visit the questions index page
      visit questions_path

      # Expect to see the questions
      questions.each do |question|
        expect(page).to have_content(question.title)
      end
    end

    scenario 'User creates a question' do
      sign_in(user)
      visit questions_path
      click_on 'New Question'

      # Fill in the form
      fill_in 'Title', with: 'Test Question Title'
      fill_in 'Body', with: 'Test Question Body with details'

      # Submit the form
      click_button 'Create Question'

      # Expect to be redirected to the question show page
      expect(page).to have_content('Test Question Title')
      expect(page).to have_content('Test Question Body with details')
      expect(page).to have_content('Question was successfully created')
    end

    scenario 'User cannot create a question with invalid data' do
      sign_in(user)
      visit new_question_path

      # Submit the form without filling it
      click_button 'Create Question'

      # Expect to see validation errors
      expect(page).to have_content("Title can't be blank")
      expect(page).to have_content("Body can't be blank")
    end

    scenario 'User views a specific question with its answers' do
      # Create a question with answers
      question = create(:question)
      answers = create_list(:answer, 3, question: question)

      # Visit the question page
      visit question_path(question)

      # Expect to see the question and its answers
      expect(page).to have_content(question.title)
      expect(page).to have_content(question.body)

      answers.each do |answer|
        expect(page).to have_content(answer.body)
      end
    end
  end
end
