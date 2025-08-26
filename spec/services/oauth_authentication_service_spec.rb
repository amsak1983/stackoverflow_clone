require 'rails_helper'

RSpec.describe OauthAuthenticationService, type: :service do
  let(:auth_hash) do
    double('auth_hash',
      provider: 'github',
      uid: '12345',
      info: double('info', email: 'user@example.com')
    )
  end
  let(:service) { described_class.new(auth_hash) }

  describe '#authenticate' do
    context 'when user exists with provider and uid' do
      let!(:existing_user) { create(:user, provider: 'github', uid: '12345') }

      it 'returns existing user' do
        result = service.authenticate

        expect(result[:success]).to be true
        expect(result[:user]).to eq(existing_user)
        expect(result[:errors]).to be_nil
      end
    end

    context 'when user exists with same email but different provider' do
      let!(:existing_user) { create(:user, email: 'user@example.com', provider: nil, uid: nil) }

      it 'updates existing user with provider info' do
        result = service.authenticate
        existing_user.reload

        expect(result[:success]).to be true
        expect(result[:user]).to eq(existing_user)
        expect(existing_user.provider).to eq('github')
        expect(existing_user.uid).to eq('12345')
      end
    end

    context 'when creating new user with email' do
      it 'creates confirmed user' do
        result = service.authenticate
        user = result[:user]

        expect(result[:success]).to be true
        expect(user).to be_persisted
        expect(user.email).to eq('user@example.com')
        expect(user.provider).to eq('github')
        expect(user.uid).to eq('12345')
        expect(user.confirmed_at).to be_present
      end
    end

    context 'when creating new user without email' do
      let(:auth_hash) do
        double('auth_hash',
          provider: 'github',
          uid: '12345',
          info: double('info', email: nil)
        )
      end

      it 'creates unconfirmed user with temp email' do
        result = service.authenticate
        user = result[:user]

        expect(result[:success]).to be true
        expect(user).to be_persisted
        expect(user.email).to eq('github_12345@temp.local')
        expect(user.provider).to eq('github')
        expect(user.uid).to eq('12345')
        expect(user.confirmed_at).to be_nil
      end
    end

    context 'when user creation fails' do
      before do
        allow(User).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(User.new))
      end

      it 'returns error response' do
        result = service.authenticate

        expect(result[:success]).to be false
        expect(result[:user]).to be_nil
        expect(result[:errors]).to be_present
      end
    end

    context 'when authentication fails with exception' do
      before do
        allow(service).to receive(:find_or_create_user).and_raise(StandardError, 'Database error')
      end

      it 'returns error response' do
        result = service.authenticate

        expect(result[:success]).to be false
        expect(result[:user]).to be_nil
        expect(result[:errors]).to include('Database error')
      end
    end
  end

  describe 'private methods' do
    describe '#find_existing_user' do
      context 'when user exists with provider and uid' do
        let!(:existing_user) { create(:user, provider: 'github', uid: '12345') }

        it 'returns the user' do
          user = service.send(:find_existing_user)
          expect(user).to eq(existing_user)
        end
      end

      context 'when user exists with email but no provider' do
        let!(:existing_user) { create(:user, email: 'user@example.com', provider: nil, uid: nil) }

        it 'updates and returns the user' do
          user = service.send(:find_existing_user)
          existing_user.reload

          expect(user).to eq(existing_user)
          expect(existing_user.provider).to eq('github')
          expect(existing_user.uid).to eq('12345')
        end
      end

      context 'when no user exists' do
        it 'returns nil' do
          user = service.send(:find_existing_user)
          expect(user).to be_nil
        end
      end

      context 'when auth_hash has no email' do
        let(:auth_hash) do
          double('auth_hash',
            provider: 'github',
            uid: '12345',
            info: double('info', email: nil)
          )
        end

        it 'returns nil even if user with same email exists' do
          create(:user, email: 'user@example.com')
          user = service.send(:find_existing_user)
          expect(user).to be_nil
        end
      end
    end

    describe '#generate_temp_email' do
      it 'generates correct temp email format' do
        temp_email = service.send(:generate_temp_email)
        expect(temp_email).to eq('github_12345@temp.local')
      end
    end

    describe '#generate_secure_password' do
      it 'generates password of correct length' do
        password = service.send(:generate_secure_password)
        expect(password.length).to eq(20)
      end

      it 'generates different passwords each time' do
        password1 = service.send(:generate_secure_password)
        password2 = service.send(:generate_secure_password)
        expect(password1).not_to eq(password2)
      end
    end
  end
end
