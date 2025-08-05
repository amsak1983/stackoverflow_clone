require 'rails_helper'

RSpec.describe "rewards/index.html.erb", type: :view do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:received_reward) { create(:reward, :awarded, question: question, recipient: user) }
  let(:created_reward) { create(:reward, question: question, user: user) }

  before do
    assign(:received_rewards, [ received_reward ])
    assign(:created_rewards, [ created_reward ])
  end

  it 'displays the page title' do
    render
    expect(rendered).to have_content('My Rewards')
  end

  it 'displays received rewards section' do
    render
    expect(rendered).to have_content('Received Rewards (1)')
  end

  it 'displays created rewards section' do
    render
    expect(rendered).to have_content('Created Rewards (1)')
  end

  context 'when user has received rewards' do
    it 'displays received reward information' do
      render
      expect(rendered).to have_content(received_reward.title)
      expect(rendered).to have_content(received_reward.question.title)
      expect(rendered).to have_content('Awarded')
    end
  end

  context 'when user has created rewards' do
    it 'displays created reward information' do
      render
      expect(rendered).to have_content(created_reward.title)
      expect(rendered).to have_content(created_reward.question.title)
    end

    context 'when reward is not awarded' do
      it 'shows pending status' do
        render
        expect(rendered).to have_content('Pending')
      end
    end
  end

  context 'when user has no rewards' do
    before do
      assign(:received_rewards, [])
      assign(:created_rewards, [])
    end

    it 'displays empty state messages' do
      render
      expect(rendered).to have_content('No rewards received yet')
      expect(rendered).to have_content('No rewards created yet')
      expect(rendered).to have_content('Ask a Question')
    end
  end
end
