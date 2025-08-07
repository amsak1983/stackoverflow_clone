require 'rails_helper'

RSpec.describe 'Question Links', type: :feature, js: true do
  include ActionView::RecordIdentifier
  scenario 'User adds a link to question' do
    user = create(:user)
    question = create(:question, user: user)

    question.links.create!(name: 'Example Link', url: 'https://example.com')

    sign_in user
    visit question_path(question)

    expect(page).to have_content('Example Link')
    expect(page).to have_link('Example Link', href: 'https://example.com')
  end

  scenario 'User removes a link from question' do
    user = create(:user)
    question = create(:question, user: user)
    link = create(:link, linkable: question, name: 'Test Link')

    expect(question.links.count).to eq(1)
    link.destroy
    expect(question.reload.links.count).to eq(0)
  end

  scenario 'User sees validation errors for invalid URL' do
    user = create(:user)
    question = create(:question, user: user)

    invalid_link = question.links.build(name: 'Invalid Link', url: 'not-a-url')
    expect(invalid_link).not_to be_valid
    expect(invalid_link.errors[:url]).to include('must be a valid HTTP or HTTPS URL')
  end

  scenario 'User sees embedded gist for gist URLs' do
    user = create(:user)
    question = create(:question, user: user)
    create(:link, linkable: question, name: 'Code Example', url: 'https://gist.github.com/user/123abc')

    sign_in user
    visit question_path(question)
    expect(page).to have_css('#gist-123abc')
  end
end
