require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:questions).dependent(:destroy) }
    it { should have_many(:answers).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
  end

  describe '#author_of?' do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }
    let(:question) { create(:question, user: user) }

    it 'returns true if user is author of record' do
      expect(user).to be_author_of(question)
    end

    it 'returns false if user is not author of record' do
      expect(another_user).not_to be_author_of(question)
    end
  end

  describe 'OAuth functionality' do
    describe '#oauth_user?' do
      it 'returns true when user has provider and uid' do
        user = build(:user, provider: 'google_oauth2', uid: '123456')
        expect(user).to be_oauth_user
      end

      it 'returns false when user has no provider' do
        user = build(:user, provider: nil, uid: '123456')
        expect(user).not_to be_oauth_user
      end

      it 'returns false when user has no uid' do
        user = build(:user, provider: 'google_oauth2', uid: nil)
        expect(user).not_to be_oauth_user
      end
    end

    describe '#email_verified?' do
      it 'returns true when user is confirmed' do
        user = build(:user, confirmed_at: Time.current)
        expect(user).to be_email_verified
      end

      it 'returns false when user is not confirmed' do
        user = build(:user, confirmed_at: nil)
        expect(user).not_to be_email_verified
      end
    end

    describe '#send_confirmation_instructions' do
      context 'with custom email (OAuth flow)' do
        let(:user) { create(:user, :oauth_user, :unconfirmed) }

        it 'uses EmailConfirmationService' do
          service = instance_double(EmailConfirmationService)
          allow(EmailConfirmationService).to receive(:new).with(user).and_return(service)
          expect(service).to receive(:send_confirmation_email).with('new@example.com')
          
          user.send_confirmation_instructions('new@example.com')
        end
      end

      context 'with standard Devise behavior (no email parameter)' do
        let(:user) { create(:user, confirmed_at: nil, provider: nil, uid: nil) }

        it 'calls super for standard Devise behavior' do
          expect(user).to receive(:send_devise_notification).with(:confirmation_instructions, anything, {})
          user.send_confirmation_instructions
        end
      end
    end

    describe '.from_omniauth' do
      let(:auth_hash) do
        OmniAuth::AuthHash.new({
          provider: 'google_oauth2',
          uid: '123456789',
          info: {
            email: 'test@example.com',
            name: 'Test User'
          }
        })
      end

      context 'when user already exists with same provider and uid' do
        let!(:existing_user) { create(:user, provider: 'google_oauth2', uid: '123456789') }

        it 'returns existing user' do
          user = User.from_omniauth(auth_hash)
          expect(user).to eq(existing_user)
        end
      end

      context 'when user exists with same email but no OAuth' do
        let!(:existing_user) { create(:user, email: 'test@example.com') }

        it 'links OAuth to existing user' do
          user = User.from_omniauth(auth_hash)
          expect(user).to eq(existing_user)
          expect(user.provider).to eq('google_oauth2')
          expect(user.uid).to eq('123456789')
        end
      end

      context 'when creating new user with email' do
        it 'creates confirmed user' do
          user = User.from_omniauth(auth_hash)
          expect(user).to be_persisted
          expect(user.email).to eq('test@example.com')
          expect(user.provider).to eq('google_oauth2')
          expect(user.uid).to eq('123456789')
          expect(user).to be_email_verified
        end
      end

      context 'when creating new user without email' do
        let(:auth_hash_no_email) do
          OmniAuth::AuthHash.new({
            provider: 'telegram',
            uid: '987654321',
            info: {
              name: 'Test User'
            }
          })
        end

        it 'creates unconfirmed user with temp email' do
          user = User.from_omniauth(auth_hash_no_email)
          expect(user).to be_persisted
          expect(user.email).to eq('telegram_987654321@temp.local')
          expect(user.provider).to eq('telegram')
          expect(user.uid).to eq('987654321')
          expect(user).not_to be_email_verified
        end
      end
    end
  end
end
