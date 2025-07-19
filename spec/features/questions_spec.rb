require 'rails_helper'

feature 'Questions viewing', %q(
  In order to find information
  As a user
  I want to be able to view questions and their answers
) do
  describe 'Any user' do
    scenario 'views the list of questions' do
      # Create some test questions
      questions = create_list(:question, 3)

      # Visit the questions index page
      visit questions_path

      # Expect to see the questions
      questions.each do |question|
        expect(page).to have_content(question.title)
      end
    end

    scenario 'views a specific question' do
      question = create(:question, title: 'Test Question', body: 'Test Body')

      visit question_path(question)

      expect(page).to have_content('Test Question')
      expect(page).to have_content('Test Body')
    end

    scenario 'views a question with its answers' do
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
