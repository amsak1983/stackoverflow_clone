require 'rails_helper'

RSpec.describe DailyDigestJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  let!(:confirmed_user1) { create(:user, confirmed_at: Time.current) }
  let!(:confirmed_user2) { create(:user, confirmed_at: Time.current) }
  let!(:unconfirmed_user) { create(:user, confirmed_at: nil) }

  before do
    ActionMailer::Base.deliveries.clear
  end

  it 'sends digest only to confirmed users with questions from last 24 hours' do
    travel_to Time.zone.parse('2025-09-08 09:00:00 UTC') do
      recent_q1 = create(:question, user: confirmed_user1, created_at: 2.hours.ago, title: 'Recent Question 1')
      recent_q2 = create(:question, user: confirmed_user2, created_at: 3.hours.ago, title: 'Recent Question 2')
      _old_q    = create(:question, user: confirmed_user1, created_at: 2.days.ago, title: 'Old Question')

      expect {
        described_class.perform_now
      }.to change { ActionMailer::Base.deliveries.size }.by(2) 

      subjects = ActionMailer::Base.deliveries.map(&:subject)
      expect(subjects).to all(include('Daily questions digest'))

      bodies = ActionMailer::Base.deliveries.map { |m| m.body.encoded }
      expect(bodies.join).to include(recent_q1.title)
      expect(bodies.join).to include(recent_q2.title)
      expect(bodies.join).not_to include('Old Question')
    end
  end
end
