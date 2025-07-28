require 'rails_helper'

feature 'Пользователь может прикреплять файлы к вопросу', %q{
  Для предоставления дополнительной информации
  Как автор вопроса
  Я хочу иметь возможность прикреплять файлы к вопросу
} do

  given(:user) { create(:user) }
  given(:pdf_file) { "#{Rails.root}/spec/fixtures/files/test.pdf" }
  given(:txt_file) { "#{Rails.root}/spec/fixtures/files/test.txt" }

  background do
    sign_in(user)
    visit new_question_path
  end

  scenario 'Пользователь может прикрепить файлы при создании вопроса', js: true do
    fill_in 'Title', with: 'Test question with files'
    fill_in 'Body', with: 'Test question with multiple file attachments'
    attach_file 'Files', [pdf_file, txt_file]
    
    click_button 'Create Question'
    
    expect(page).to have_content 'Test question with files'
    expect(page).to have_content 'Test question with multiple file attachments'
    expect(page).to have_content 'test.pdf'
    expect(page).to have_content 'test.txt'
  end

  scenario 'Пользователь может прикрепить файлы при редактировании вопроса', js: true do
    # Создаем вопрос без файлов
    question = create(:question, user: user)
    visit question_path(question)
    
    # Кликаем на редактировать
    within("#question_#{question.id}") do
      click_on 'Edit'
      attach_file 'Files', pdf_file
      click_on 'Update Question'
    end
    
    # Проверяем что файл прикреплен
    expect(page).to have_content 'test.pdf'
  end
  
  scenario 'Автор может удалить прикрепленный файл', js: true do
    # Создаем вопрос с файлом
    question = create(:question, user: user)
    question.files.attach(io: File.open(pdf_file), filename: 'test.pdf')
    
    visit question_path(question)
    expect(page).to have_content 'test.pdf'
    
    # Удаляем файл
    within("#attachment_#{question.files.first.id}") do
      click_on '✕'
    end
    
    # Проверяем, что файла больше нет
    expect(page).not_to have_content 'test.pdf'
  end
  
  scenario 'Не автор не видит кнопку удаления файла', js: true do
    # Создаем вопрос другого пользователя
    other_user = create(:user)
    question = create(:question, user: other_user)
    question.files.attach(io: File.open(pdf_file), filename: 'test.pdf')
    
    visit question_path(question)
    
    # Проверяем, что файл есть, но кнопки удаления нет
    expect(page).to have_content 'test.pdf'
    expect(page).not_to have_link '✕'
  end
end
