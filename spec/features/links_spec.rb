require 'rails_helper'

feature 'User can add links to question', %q{
  In order to provide additional info to my question
  As an question's author
  I'd like to be able to add links
} do

  given(:user) { create(:user) }
  given(:gist_url) { 'https://gist.github.com/example/123456789' }
  given(:simple_url) { 'https://example.com' }

  scenario 'User adds links when asks question', js: true do
    sign_in(user)
    visit new_question_path

    fill_in 'Title', with: 'Test question'
    fill_in 'Body', with: 'text text text'

    click_on 'Добавить ссылку'

    within all('.nested-fields').first do
      fill_in 'Название', with: 'My gist'
      fill_in 'Ссылка', with: gist_url
    end

    click_on 'Добавить ссылку'

    within all('.nested-fields').last do
      fill_in 'Название', with: 'My link'
      fill_in 'Ссылка', with: simple_url
    end

    click_on 'Ask'

    expect(page).to have_link 'My link', href: simple_url
    expect(page).to have_content 'My gist'
  end
end

feature 'User can add links to answer', %q{
  In order to provide additional info to my answer
  As an answer's author
  I'd like to be able to add links
} do

  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given(:gist_url) { 'https://gist.github.com/example/123456789' }
  given(:simple_url) { 'https://example.com' }

  scenario 'User adds links when creates answer', js: true do
    sign_in(user)
    visit question_path(question)

    fill_in 'Body', with: 'My answer'

    click_on 'Добавить ссылку'

    within all('.nested-fields').first do
      fill_in 'Название', with: 'My gist'
      fill_in 'Ссылка', with: gist_url
    end

    click_on 'Добавить ссылку'

    within all('.nested-fields').last do
      fill_in 'Название', with: 'My link'
      fill_in 'Ссылка', with: simple_url
    end

    click_on 'Answer'

    within '.answers' do
      expect(page).to have_link 'My link', href: simple_url
      expect(page).to have_content 'My gist'
    end
  end
end

feature 'User can delete links', %q{
  In order to remove unnecessary links
  As an author of question or answer
  I'd like to be able to delete links
} do

  given(:user) { create(:user) }
  given(:another_user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:link) { create(:link, linkable: question) }

  scenario 'Author deletes link from question', js: true do
    sign_in(user)
    visit question_path(question)

    expect(page).to have_link link.name, href: link.url

    within '.links' do
      click_on '✕'
    end

    expect(page).to_not have_link link.name, href: link.url
  end

  scenario 'Non-author cannot delete link', js: true do
    sign_in(another_user)
    visit question_path(question)

    expect(page).to have_link link.name, href: link.url
    expect(page).to_not have_link '✕'
  end

  scenario 'Unauthenticated user cannot delete link' do
    visit question_path(question)

    expect(page).to have_link link.name, href: link.url
    expect(page).to_not have_link '✕'
  end
end
