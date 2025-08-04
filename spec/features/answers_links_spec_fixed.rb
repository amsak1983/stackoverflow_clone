require 'rails_helper'

feature 'User can add links to answer', %q{
  In order to provide additional info to my answer
  As an answer's author
  I'd like to be able to add links
} do

  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given(:answer) { create(:answer, question: question, user: user) }
  given(:gist_url) { 'https://gist.github.com/username/12345' }
  given(:regular_url) { 'https://google.com' }
  given(:other_user) { create(:user) }

  background do
    # Make sure we're signed in before each test
    sign_in(user)
  end

  describe 'User adds links when creates answer' do
    background do
      visit question_path(question)
    end

    scenario 'User adds link when creates answer', js: true do
      # Fill in the answer body
      fill_in 'answer[body]', with: 'Answer text'
      
      # Click the Add link button
      click_on 'Add link'
      
      # Wait for form fields to appear with longer timeout
      sleep 2
      
      # Fill in the fields directly without using within
      fill_in 'Name', with: 'My gist'
      fill_in 'URL', with: gist_url
      
      click_on 'Post Answer'

      within '.answers' do
        expect(page).to have_link 'My gist', href: gist_url
      end
    end

    scenario 'User adds multiple links when creates answer', js: true do
      # Fill in the answer body
      fill_in 'answer[body]', with: 'Answer text'
      
      # Add first link
      click_on 'Add link'
      sleep 2
      
      # Fill in first link fields directly
      first('input[name$="[name]"]').set('My gist')
      first('input[name$="[url]"]').set(gist_url)
      
      # Add second link
      click_on 'Add link'
      sleep 2
      
      # Fill in second link fields
      # Use all to get the second set of fields
      all('input[name$="[name]"]').last.set('Google')
      all('input[name$="[url]"]').last.set(regular_url)
      
      click_on 'Post Answer'

      within '.answers' do
        expect(page).to have_link 'My gist', href: gist_url
        expect(page).to have_link 'Google', href: regular_url
      end
    end

    scenario 'User tries to add invalid link when creates answer', js: true do
      # Fill in the answer body
      fill_in 'answer[body]', with: 'Answer text'
      
      # Add link
      click_on 'Add link'
      sleep 2
      
      # Fill in invalid link directly
      first('input[name$="[name]"]').set('Invalid link')
      first('input[name$="[url]"]').set('invalid-url')
      
      click_on 'Post Answer'

      expect(page).to have_content 'Links must be valid URLs, starting with http:// or https://'
    end
  end

  describe 'User adds links when edits answer' do
    given!(:answer) { create(:answer, question: question, user: user) }

    background do
      visit question_path(question)
      # First find the answer, then click the Edit button
      within "#answer_#{answer.id}" do
        click_on 'Edit'
      end
    end

    scenario 'User adds link when edits answer', js: true do
      # First find the edit form
      expect(page).to have_css('form.edit_answer')
      
      # Use the form class instead of ID
      within 'form.edit_answer' do
        click_on 'Add link'
        sleep 2
        
        # Fill in fields directly
        first('input[name$="[name]"]').set('My gist')
        first('input[name$="[url]"]').set(gist_url)
        
        click_on 'Update Answer'
      end

      expect(page).to have_link 'My gist', href: gist_url
    end
  end

  describe 'User deletes links from answer' do
    given!(:answer) { create(:answer, question: question, user: user) }
    given!(:link) { create(:link, linkable: answer, name: 'Google', url: regular_url) }

    scenario 'User deletes link from answer', js: true do
      visit question_path(question)
      
      # Check that the answer is on the page
      expect(page).to have_content(answer.body)
      
      # Click edit on the answer (find by content instead of ID)
      within '.answers' do
        within '.answer', text: answer.body do
          click_on 'Edit'
        end
      end
      
      # Wait for edit form to appear
      expect(page).to have_css('form.edit_answer')
      
      # Find and click the link deletion button in the edit form
      within 'form.edit_answer' do
        # Make sure link is visible
        expect(page).to have_content('Google')
        
        # Click remove link button
        click_on 'Remove link'
        click_on 'Update Answer'
      end
      
      # Check that the link has disappeared
      within '.answers' do
        expect(page).not_to have_link 'Google', href: regular_url
      end
    end

    scenario 'Non-author cannot delete link from answer', js: true do
      # Create a different user and sign in as them
      sign_in(other_user)
      
      visit question_path(question)
      
      # Check that the answer is on the page
      expect(page).to have_content(answer.body)
      
      # Check that the link is displayed on the page
      within '.answers' do
        within '.answer', text: answer.body do
          expect(page).to have_link 'Google', href: regular_url
          # Check that there is no ability to edit the answer
          expect(page).not_to have_link 'Edit'
        end
      end
    end
  end

  describe 'GitHub Gist embedding' do
    given!(:answer) { create(:answer, question: question, user: user) }
    given!(:gist_link) { create(:link, :gist, linkable: answer, name: 'My gist', url: gist_url) }

    scenario 'Gist link is embedded', js: true do
      visit question_path(question)
      
      # Check that the answer is on the page
      expect(page).to have_content(answer.body)
      
      # Check that the gist link is displayed and embedded
      within '.answers' do
        within '.answer', text: answer.body do
          expect(page).to have_link 'My gist', href: gist_url
          expect(page).to have_css('.gist-embed')
        end
      end
    end
  end
end
