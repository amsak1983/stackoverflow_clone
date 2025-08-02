require 'rails_helper'

feature 'User can add links to answer', %q{
  In order to provide additional info to my answer
  As an answer's author
  I'd like to be able to add links
} do

  given(:user) { create(:user) }
  given!(:question) { create(:question) }
  given(:gist_url) { 'https://gist.github.com/username/12345' }
  given(:regular_url) { 'https://google.com' }

  describe 'User adds links when creates answer' do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'User adds link when creates answer', js: true do
      fill_in 'Your answer', with: 'Answer text'

      click_on 'Add link'

      within '.nested-fields' do
        fill_in 'Name', with: 'My gist'
        fill_in 'URL', with: gist_url
      end

      click_on 'Create answer'

      within '.answers' do
        expect(page).to have_link 'My gist', href: gist_url
      end
    end

    scenario 'User adds multiple links when creates answer', js: true do
      fill_in 'Your answer', with: 'Answer text'

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

      click_on 'Create answer'

      within '.answers' do
        expect(page).to have_link 'My gist', href: gist_url
        expect(page).to have_link 'Google', href: regular_url
      end
    end

    scenario 'User tries to add invalid link when creates answer', js: true do
      fill_in 'Your answer', with: 'Answer text'

      click_on 'Add link'

      within '.nested-fields' do
        fill_in 'Name', with: 'Invalid link'
        fill_in 'URL', with: 'invalid-url'
      end

      click_on 'Create answer'

      expect(page).to have_content 'Links url must be a valid URL starting with http:// or https://'
    end
  end

  describe 'User adds links when edits answer' do
    given!(:answer) { create(:answer, question: question, user: user) }

    background do
      sign_in(user)
      visit question_path(question)
      click_on 'Edit'
    end

    scenario 'User adds link when edits answer', js: true do
      within "#edit-answer-#{answer.id}" do
        click_on 'Add link'

        within '.nested-fields' do
          fill_in 'Name', with: 'My gist'
          fill_in 'URL', with: gist_url
        end

        click_on 'Save'
      end

      expect(page).to have_link 'My gist', href: gist_url
    end
  end

  describe 'User deletes links from answer' do
    given!(:answer) { create(:answer, question: question, user: user) }
    given!(:link) { create(:link, linkable: answer, name: 'Google', url: regular_url) }

    scenario 'User deletes link from answer', js: true do
      sign_in(user)
      visit question_path(question)

      expect(page).to have_link 'Google', href: regular_url

      click_on 'Edit'

      within "#edit-answer-#{answer.id}" do
        click_on 'Remove link'
        click_on 'Save'
      end

      expect(page).to_not have_link 'Google', href: regular_url
    end

    scenario 'Non-author cannot delete link from answer' do
      other_user = create(:user)
      sign_in(other_user)
      visit question_path(question)

      expect(page).to have_link 'Google', href: regular_url
      expect(page).to_not have_link 'Edit'
    end
  end

  describe 'GitHub Gist embedding' do
    given!(:answer) { create(:answer, question: question, user: user) }
    given!(:gist_link) { create(:link, linkable: answer, name: 'My gist', url: gist_url) }

    scenario 'Gist link is embedded', js: true do
      sign_in(user)
      visit question_path(question)

      within '.answers' do
        expect(page).to have_link 'My gist', href: gist_url
        expect(page).to have_css('.gist-embed')
      end
    end
  end
end
