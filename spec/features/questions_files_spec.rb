require 'rails_helper'

feature 'User can attach files to question', %q{
  In order to provide additional information
  As an author of question
  I want to be able to attach files to question
} do

  given(:user) { create(:user) }
  given(:pdf_file) { "#{Rails.root}/spec/fixtures/files/test.pdf" }
  given(:txt_file) { "#{Rails.root}/spec/fixtures/files/test.txt" }

  background do
    sign_in(user)
    visit new_question_path
  end

  scenario 'User can attach files when creating a question' do
    fill_in 'Title', with: 'Test question with files'
    fill_in 'Body', with: 'Test question with multiple file attachments'
    attach_file 'Files', [pdf_file, txt_file]
    
    click_button 'Create Question'
    
    expect(page).to have_content 'Test question with files'
    expect(page).to have_content 'Test question with multiple file attachments'
    expect(page).to have_content 'test.pdf'
    expect(page).to have_content 'test.txt'
  end

  scenario 'User can attach files when editing a question' do
    # Create question without files
    question = create(:question, user: user)
    visit question_path(question)
    
    # Click on edit outside the within block
    click_on 'Edit'
    
    # Ждем появления поля загрузки файлов
    expect(page).to have_field('Files')
    
    # Загружаем файл и обновляем вопрос
    attach_file 'Files', pdf_file
    click_on 'Update Question'
    
    # Check that file is attached
    expect(page).to have_content 'test.pdf'
  end
  
  scenario 'Author can delete attached file' do
    # Create question with file
    question = create(:question, user: user)
    question.files.attach(io: File.open(pdf_file), filename: 'test.pdf')
    
    visit question_path(question)
    expect(page).to have_content 'test.pdf'
    
    # Delete file
    within("#attachment_#{question.files.first.id}") do
      click_on '✕'
    end
    
    # Check that file no longer exists
    expect(page).not_to have_content 'test.pdf'
  end
  
  scenario 'Non-author cannot see delete button' do
    # Create question by another user
    other_user = create(:user)
    question = create(:question, user: other_user)
    question.files.attach(io: File.open(pdf_file), filename: 'test.pdf')
    
    visit question_path(question)
    
    # Check that file exists but delete button is not visible
    expect(page).to have_content 'test.pdf'
    expect(page).not_to have_link '✕'
  end
end
