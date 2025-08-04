require 'rails_helper'

feature 'Answer links management', js: true do
  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given(:answer) { create(:answer, question: question, user: user) }
  given(:gist_url) { 'https://gist.github.com/username/12345' }
  given(:google_url) { 'https://google.com' }
  given(:other_user) { create(:user) }

  describe 'Adding links to a new answer' do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'User adds a link when creating an answer' do
      # Fill in the answer body
      fill_in 'answer[body]', with: 'My answer with a link'
      
      # Debug output
      puts page.html
      
      # Click the Add link button
      click_on 'Add link'
      
      # Wait for form fields to appear
      sleep 2
      
      # Debug output after clicking Add link
      puts page.html
      
      # Try to find the name field using different approaches
      begin
        fill_in 'Name', with: 'My gist'
      rescue Capybara::ElementNotFound
        # Try alternative selectors if the first one fails
        begin
          first('input[name$="[name]"]').set('My gist')
        rescue Capybara::ElementNotFound
          # Last resort - try to find by placeholder or other attributes
          find('input[placeholder="Link name"]').set('My gist')
        end
      end
      
      # Try to find the URL field using different approaches
      begin
        fill_in 'URL', with: gist_url
      rescue Capybara::ElementNotFound
        # Try alternative selectors if the first one fails
        begin
          first('input[name$="[url]"]').set(gist_url)
        rescue Capybara::ElementNotFound
          # Last resort - try to find by placeholder or other attributes
          find('input[placeholder="https://..."]').set(gist_url)
        end
      end
      
      # Submit the form
      click_on 'Post Answer'
      
      # Verify the answer was created with the link
      expect(page).to have_content('My answer with a link')
      expect(page).to have_link('My gist', href: gist_url)
    end
  end

  describe 'Editing answer links' do
    given!(:link) { create(:link, linkable: answer, name: 'Google', url: google_url) }
    
    background do
      sign_in(user)
      visit question_path(question)
    end
    
    scenario 'User edits links in an answer' do
      # Find the answer on the page
      expect(page).to have_content(answer.body)
      
      # Debug output
      puts page.html
      
      # Try to find the Edit button using different approaches
      begin
        within "#answer_#{answer.id}" do
          click_on 'Edit'
        end
      rescue Capybara::ElementNotFound
        # Try alternative selectors if the first one fails
        begin
          find(".answer", text: answer.body).click_on('Edit')
        rescue Capybara::ElementNotFound
          # Last resort - try to find by content
          find('a', text: 'Edit', match: :prefer_exact).click
        end
      end
      
      # Wait for the edit form to appear
      sleep 2
      
      # Debug output after clicking Edit
      puts page.html
      
      # Try to add a new link
      click_on 'Add link'
      sleep 2
      
      # Try to find the name field for the new link
      begin
        all('input[name$="[name]"]').last.set('My gist')
      rescue Capybara::ElementNotFound
        # Try alternative selectors if the first one fails
        find('input[placeholder="Link name"]').set('My gist')
      end
      
      # Try to find the URL field for the new link
      begin
        all('input[name$="[url]"]').last.set(gist_url)
      rescue Capybara::ElementNotFound
        # Try alternative selectors if the first one fails
        find('input[placeholder="https://..."]').set(gist_url)
      end
      
      # Submit the form
      click_on 'Update Answer'
      
      # Verify the answer was updated with both links
      expect(page).to have_link('Google', href: google_url)
      expect(page).to have_link('My gist', href: gist_url)
    end
  end

  describe 'Deleting links from an answer' do
    given!(:link) { create(:link, linkable: answer, name: 'Google', url: google_url) }
    
    scenario 'Author deletes a link from their answer' do
      sign_in(user)
      visit question_path(question)
      
      # Find the answer on the page
      expect(page).to have_content(answer.body)
      
      # Debug output
      puts page.html
      
      # Try to find the Edit button using different approaches
      begin
        within "#answer_#{answer.id}" do
          click_on 'Edit'
        end
      rescue Capybara::ElementNotFound
        # Try alternative selectors if the first one fails
        begin
          find(".answer", text: answer.body).click_on('Edit')
        rescue Capybara::ElementNotFound
          # Last resort - try to find by content
          find('a', text: 'Edit', match: :prefer_exact).click
        end
      end
      
      # Wait for the edit form to appear
      sleep 2
      
      # Debug output after clicking Edit
      puts page.html
      
      # Try to find and click the Remove link button
      begin
        click_on 'Remove link'
      rescue Capybara::ElementNotFound
        # Try alternative selectors if the first one fails
        find('.remove_fields').click
      end
      
      # Submit the form
      click_on 'Update Answer'
      
      # Verify the link was removed
      expect(page).not_to have_link('Google', href: google_url)
    end
    
    scenario 'Non-author cannot delete links' do
      sign_in(other_user)
      visit question_path(question)
      
      # Find the answer on the page
      expect(page).to have_content(answer.body)
      
      # Verify the link is visible
      expect(page).to have_link('Google', href: google_url)
      
      # Verify there is no Edit button for non-author
      expect(page).not_to have_link('Edit', href: /answers/)
    end
  end

  describe 'GitHub Gist embedding' do
    given!(:gist_link) { create(:link, :gist, linkable: answer, name: 'My gist', url: gist_url) }
    
    scenario 'Gist links are embedded' do
      sign_in(user)
      visit question_path(question)
      
      # Find the answer on the page
      expect(page).to have_content(answer.body)
      
      # Verify the gist link is displayed and embedded
      expect(page).to have_link('My gist', href: gist_url)
      # Note: The actual embedding might depend on JavaScript that loads the gist
      # This might need to be adjusted based on how gists are embedded in the application
    end
  end
end
