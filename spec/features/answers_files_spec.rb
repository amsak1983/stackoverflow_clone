require 'rails_helper'

feature 'Пользователь может прикреплять файлы к ответу', %q{
  Для предоставления дополнительной информации
  Как автор ответа
  Я хочу иметь возможность прикреплять файлы к ответу
} do

  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given(:pdf_file) { "#{Rails.root}/spec/fixtures/files/test.pdf" }
  given(:txt_file) { "#{Rails.root}/spec/fixtures/files/test.txt" }

  background do
    sign_in(user)
    visit question_path(question)
  end

  scenario 'Пользователь может прикрепить файлы при создании ответа', js: true do
    within('#new_answer') do
      fill_in 'answer[body]', with: 'Ответ с прикрепленными файлами'
      attach_file 'Files', [pdf_file, txt_file]
      click_on 'Post Answer'
    end
    
    expect(page).to have_content 'Ответ с прикрепленными файлами'
    expect(page).to have_content 'test.pdf'
    expect(page).to have_content 'test.txt'
  end

  scenario 'Пользователь может прикрепить файлы при редактировании своего ответа', js: true do
    # Создаем ответ без файлов
    answer = create(:answer, question: question, user: user)
    visit question_path(question)
    
    # Редактируем ответ
    within("#answer_#{answer.id}") do
      click_on 'Edit'
      attach_file 'Files', pdf_file
      click_on 'Update Answer'
    end
    
    # Проверяем что файл прикреплен
    expect(page).to have_content 'test.pdf'
  end
  
  scenario 'Автор может удалить прикрепленный к ответу файл', js: true do
    # Создаем ответ с файлом
    answer = create(:answer, question: question, user: user)
    answer.files.attach(io: File.open(pdf_file), filename: 'test.pdf')
    
    visit question_path(question)
    expect(page).to have_content 'test.pdf'
    
    # Удаляем файл
    within("#attachment_#{answer.files.first.id}") do
      click_on '✕'
    end
    
    # Проверяем, что файла больше нет
    expect(page).not_to have_content 'test.pdf'
  end
  
  scenario 'Не автор не видит кнопку удаления файла в ответе', js: true do
    # Создаем ответ другого пользователя
    other_user = create(:user)
    answer = create(:answer, question: question, user: other_user)
    answer.files.attach(io: File.open(pdf_file), filename: 'test.pdf')
    
    visit question_path(question)
    
    # Проверяем, что файл есть, но кнопки удаления нет
    expect(page).to have_content 'test.pdf'
    expect(page).not_to have_link '✕'
  end
end
