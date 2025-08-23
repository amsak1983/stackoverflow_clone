require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe '#email_confirmation' do
    let(:user) { create(:user, confirmation_token: 'abc123', unconfirmed_email: 'test@example.com') }
    let(:mail) { UserMailer.email_confirmation(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Confirm your email address')
      expect(mail.to).to eq([user.unconfirmed_email])
      expect(mail.from).to eq(['noreply@stackoverflow-clone.com'])
    end

    it 'renders the body' do
      expect(mail.html_part.body.to_s).to include('Email Address Confirmation')
      expect(mail.text_part.body.to_s).to include('Hello!')
    end

    it 'includes confirmation link' do
      expect(mail.html_part.body.to_s).to include(confirm_user_email_confirmation_url(user, confirmation_token: user.confirmation_token))
    end
  end
end
