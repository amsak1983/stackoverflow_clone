require 'rails_helper'

feature 'User can attach files to answer', %q(
  In order to provide additional information
  As an author of answer
  I want to be able to attach files to answer
) do
  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given(:pdf_file) { "#{Rails.root}/spec/fixtures/files/test.pdf" }
  given(:txt_file) { "#{Rails.root}/spec/fixtures/files/test.txt" }

  background do
    sign_in(user)
    visit question_path(question)
  end

  scenario 'User can attach files when creating an answer' do
    within('#new_answer') do
      fill_in 'answer[body]', with: 'Answer with attached files'
      attach_file 'Files', [ pdf_file, txt_file ]
      click_on 'Post Answer'
    end

    expect(page).to have_content 'Answer with attached files'
    expect(page).to have_content 'test.pdf'
    expect(page).to have_content 'test.txt'
  end

  scenario 'User can attach files when editing their answer' do
    # Create answer without files
    answer = create(:answer, question: question, user: user)
    visit question_path(question)

    # Edit the answer
    within("#answer_#{answer.id}") do
      click_on 'Edit'
      attach_file 'Files', pdf_file
      click_on 'Update Answer'
    end

    # Check that file is attached
    expect(page).to have_content 'test.pdf'
  end

  scenario 'Author can delete attached file from answer' do
    # Create answer with file
    answer = create(:answer, question: question, user: user)
    answer.files.attach(io: File.open(pdf_file), filename: 'test.pdf')

    visit question_path(question)
    expect(page).to have_content 'test.pdf'

    # Delete file
    within("#answer_attachment_#{answer.files.first.id}") do
      click_on '✕'
    end

    # Check that file no longer exists
    expect(page).not_to have_content 'test.pdf'
  end

  scenario 'Non-author cannot see delete button for answer attachments' do
    # Create answer by another user
    other_user = create(:user)
    answer = create(:answer, question: question, user: other_user)
    answer.files.attach(io: File.open(pdf_file), filename: 'test.pdf')

    visit question_path(question)

    # Check that file exists but delete button is not visible
    expect(page).to have_content 'test.pdf'
    expect(page).not_to have_link '✕'
  end
end
