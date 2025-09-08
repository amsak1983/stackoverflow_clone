require 'rails_helper'

RSpec.describe AnswerMailer, type: :mailer do
  before { ActionMailer::Base.deliveries.clear }

  it 'composes new answer email with proper subject and content' do
    user = create(:user, confirmed_at: Time.current)
    author = create(:user, confirmed_at: Time.current)
    question = create(:question, user: author, title: 'How to test mailers?')
    answer = create(:answer, question: question, user: author, body: 'Use RSpec mailer specs')

    mail = described_class.new_answer(user, answer)

    expect(mail.to).to eq([ user.email ])
    expect(mail.subject).to include('New answer to your question')
    expect(mail.body.encoded).to include('How to test mailers?')
    expect(mail.body.encoded).to include('Use RSpec mailer specs')
  end
end
