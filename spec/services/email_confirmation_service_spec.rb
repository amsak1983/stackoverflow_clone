require 'rails_helper'

RSpec.describe EmailConfirmationService, type: :service do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }
  let(:valid_email) { 'new@example.com' }
  let(:invalid_email) { 'invalid-email' }

  describe '#send_confirmation_email' do
    context 'with valid email' do
      it 'updates user with confirmation details' do
        allow(UserMailer).to receive_message_chain(:email_confirmation, :deliver_now)

        expect {
          service.send_confirmation_email(valid_email)
        }.to change { user.reload.unconfirmed_email }.to(valid_email)
          .and change { user.confirmation_token }.from(nil)
          .and change { user.confirmation_sent_at }.from(nil)
      end

      it 'sends confirmation email' do
        mailer_double = double('mailer')
        expect(UserMailer).to receive(:email_confirmation).with(user).and_return(mailer_double)
        expect(mailer_double).to receive(:deliver_now)

        service.send_confirmation_email(valid_email)
      end

      it 'returns success response' do
        allow(UserMailer).to receive_message_chain(:email_confirmation, :deliver_now)

        result = service.send_confirmation_email(valid_email)

        expect(result[:success]).to be true
        expect(result[:message]).to eq("Confirmation email sent to #{valid_email}")
      end
    end

    context 'with invalid email' do
      it 'returns error response' do
        result = service.send_confirmation_email(invalid_email)

        expect(result[:success]).to be false
        expect(result[:errors]).to include('Invalid email format')
      end

      it 'does not update user' do
        expect {
          service.send_confirmation_email(invalid_email)
        }.not_to change { user.reload.attributes }
      end
    end

    context 'when mailer fails' do
      it 'returns error response' do
        allow(UserMailer).to receive(:email_confirmation).and_raise(StandardError, 'Mail server error')

        result = service.send_confirmation_email(valid_email)

        expect(result[:success]).to be false
        expect(result[:errors]).to include('Mail server error')
      end
    end
  end

  describe '#confirm_email' do
    let(:token) { 'valid_token' }

    before do
      user.update!(
        unconfirmed_email: valid_email,
        confirmation_token: token,
        confirmation_sent_at: 1.hour.ago
      )
    end

    context 'with valid token' do
      it 'confirms email and updates user' do
        result = service.confirm_email(token)
        user.reload

        expect(user.email).to eq(valid_email)
        expect(user.unconfirmed_email).to be_nil
        expect(user.confirmation_token).to be_nil
        expect(user.confirmation_sent_at).to be_nil
        expect(user.confirmed_at).to be_present
      end

      it 'returns success response' do
        result = service.confirm_email(token)

        expect(result[:success]).to be true
        expect(result[:message]).to eq('Email successfully confirmed! Welcome!')
      end
    end

    context 'with invalid token' do
      it 'returns error response' do
        result = service.confirm_email('wrong_token')

        expect(result[:success]).to be false
        expect(result[:errors]).to include('Invalid or expired confirmation link')
      end
    end

    context 'with expired token' do
      before do
        user.update!(confirmation_sent_at: 4.days.ago)
      end

      it 'returns error response' do
        result = service.confirm_email(token)

        expect(result[:success]).to be false
        expect(result[:errors]).to include('Invalid or expired confirmation link')
      end
    end

    context 'when user has no unconfirmed_email' do
      before do
        user.update!(unconfirmed_email: nil)
      end

      it 'returns error response' do
        result = service.confirm_email(token)

        expect(result[:success]).to be false
        expect(result[:errors]).to include('Invalid or expired confirmation link')
      end
    end
  end

  describe '.find_user_by_token' do
    let(:token) { 'test_token' }

    before do
      user.update!(confirmation_token: token)
    end

    it 'finds user by id and token' do
      found_user = described_class.find_user_by_token(user.id, token)
      expect(found_user).to eq(user)
    end

    it 'returns nil for wrong token' do
      found_user = described_class.find_user_by_token(user.id, 'wrong_token')
      expect(found_user).to be_nil
    end

    it 'returns nil for wrong user id' do
      found_user = described_class.find_user_by_token(999, token)
      expect(found_user).to be_nil
    end
  end

  describe 'private methods' do
    describe '#valid_email?' do
      it 'validates email format correctly' do
        expect(service.send(:valid_email?, 'test@example.com')).to be true
        expect(service.send(:valid_email?, 'invalid-email')).to be false
        expect(service.send(:valid_email?, nil)).to be false
        expect(service.send(:valid_email?, '')).to be false
      end
    end

    describe '#token_expired?' do
      context 'when confirmation_sent_at is nil' do
        before { user.update!(confirmation_sent_at: nil) }

        it 'returns true' do
          expect(service.send(:token_expired?)).to be true
        end
      end

      context 'when token is expired' do
        before { user.update!(confirmation_sent_at: 4.days.ago) }

        it 'returns true' do
          expect(service.send(:token_expired?)).to be true
        end
      end

      context 'when token is not expired' do
        before { user.update!(confirmation_sent_at: 1.hour.ago) }

        it 'returns false' do
          expect(service.send(:token_expired?)).to be false
        end
      end
    end
  end
end
