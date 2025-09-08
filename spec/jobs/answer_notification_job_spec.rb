require 'rails_helper'

RSpec.describe AnswerNotificationJob, type: :job do
  before do
    ActionMailer::Base.deliveries.clear
  end

  let!(:author) { create(:user, confirmed_at: Time.current) }
  let!(:other_subscriber) { create(:user, confirmed_at: Time.current) }
  let!(:answer_author) { create(:user, confirmed_at: Time.current) }

  let!(:question) { create(:question, user: author) }

  it 'notifies all subscribers except the answer author' do
    create(:subscription, user: other_subscriber, question: question)

    answer = create(:answer, question: question, user: answer_author)

    expect {
      described_class.perform_now(answer.id)
    }.to change { ActionMailer::Base.deliveries.size }.by(2)

    recipients = ActionMailer::Base.deliveries.map { |m| m.to }.flatten
    expect(recipients).to include(author.email, other_subscriber.email)
    expect(recipients).not_to include(answer_author.email)

    subjects = ActionMailer::Base.deliveries.map(&:subject)
    expect(subjects).to all(include('New answer to your question'))
  end
end
