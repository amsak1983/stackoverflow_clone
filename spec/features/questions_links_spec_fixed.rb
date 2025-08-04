require 'rails_helper'

feature 'User can add links to question', %q{
  In order to provide additional info to my question
  As an question's author
  I'd like to be able to add links
} do

  given(:user) { create(:user) }
  given(:gist_url) { 'https://gist.github.com/username/12345' }
  given(:regular_url) { 'https://google.com' }

  describe 'User adds links when asks question' do
    background do
      sign_in(user)
      visit new_question_path

      fill_in 'question[title]', with: 'Test question'
      fill_in 'question[body]', with: 'Test question text'
    end

    scenario 'User adds link when asks question', js: true do
      click_on 'Add link'

      within '.nested-fields' do
        fill_in 'Name', with: 'My gist'
        fill_in 'URL', with: gist_url
      end

      click_on 'Ask Question'

      expect(page).to have_link 'My gist', href: gist_url
    end

    scenario 'User adds multiple links when asks question', js: true do
      click_on 'Add link'

      within all('.nested-fields')[0] do
        fill_in 'Name', with: 'My gist'
        fill_in 'URL', with: gist_url
      end

      click_on 'Add link'

      within all('.nested-fields')[1] do
        fill_in 'Name', with: 'Google'
        fill_in 'URL', with: regular_url
      end

      click_on 'Ask Question'

      expect(page).to have_link 'My gist', href: gist_url
      expect(page).to have_link 'Google', href: regular_url
    end

    scenario 'User tries to add invalid link when asks question', js: true do
      click_on 'Add link'

      within '.nested-fields' do
        fill_in 'Name', with: 'Invalid link'
        fill_in 'URL', with: 'invalid-url'
      end

      click_on 'Ask Question'

      expect(page).to have_content 'Links must be valid URLs, starting with http:// or https://'
    end
  end

  describe 'User adds links when edits question' do
    given!(:question) { create(:question, user: user) }

    background do
      sign_in(user)
      visit question_path(question)
      click_on 'Edit'
    end

    scenario 'User adds link when edits question', js: true do
      within "#question_#{question.id}" do
        click_on 'Add link'

        within '.nested-fields' do
          fill_in 'Name', with: 'My gist'
          fill_in 'URL', with: gist_url
        end

        click_on 'Update Question'
      end

      expect(page).to have_link 'My gist', href: gist_url
    end
  end

  describe 'User deletes links from question' do
    given!(:question) { create(:question, user: user) }
    given!(:link) { create(:link, linkable: question, name: 'Google', url: regular_url) }

    scenario 'User deletes link from question', js: true do
      sign_in(user)
      visit question_path(question)

      expect(page).to have_link 'Google', href: regular_url

      click_on 'Edit'

      within "#question_#{question.id}" do
        within '.nested-fields' do
          click_on '✕'
        end
        click_on 'Update Question'
      end

      expect(page).to_not have_link 'Google', href: regular_url
    end

    scenario 'Non-author cannot delete link from question' do
      other_user = create(:user)
      sign_in(other_user)
      visit question_path(question)

      expect(page).to have_link 'Google', href: regular_url
      expect(page).to_not have_link 'Edit'
    end
  end

  describe 'GitHub Gist embedding' do
    given!(:question) { create(:question, user: user) }
    given!(:gist_link) { create(:link, linkable: question, name: 'My gist', url: gist_url) }

    scenario 'Gist link is embedded', js: true do
      sign_in(user)
      visit question_path(question)

      expect(page).to have_link 'My gist', href: gist_url
      expect(page).to have_css('.gist-embed')
    end
  end
end
