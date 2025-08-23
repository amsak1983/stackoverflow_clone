require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @request.env["omniauth.auth"] = auth_hash
    routes { Rails.application.routes }
  end

  describe '#google_oauth2' do
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

    before do
      request.env["omniauth.auth"] = auth_hash
    end

    context 'when user is successfully created and verified' do
      it 'signs in user and redirects to root' do
        expect {
          get :google_oauth2
        }.to change(User, :count).by(1)

        user = User.last
        expect(user.email).to eq('test@example.com')
        expect(user.provider).to eq('google_oauth2')
        expect(user.uid).to eq('123456789')
        expect(user).to be_email_verified

        expect(response).to redirect_to(root_path)
        expect(controller.current_user).to eq(user)
      end
    end

    context 'when user exists but is not verified' do
      let(:auth_hash_no_email) do
        OmniAuth::AuthHash.new({
          provider: 'google_oauth2',
          uid: '123456789',
          info: {
            name: 'Test User'
          }
        })
      end

      before do
        request.env["omniauth.auth"] = auth_hash_no_email
      end

      it 'redirects to email confirmation' do
        get :google_oauth2

        user = User.last
        expect(user).not_to be_email_verified
        expect(session[:oauth_user_id]).to eq(user.id)
        expect(response).to redirect_to(new_user_email_confirmation_path)
      end
    end

    context 'when user creation fails' do
      it 'handles authentication service failure' do
        service = instance_double(OauthAuthenticationService)
        allow(OauthAuthenticationService).to receive(:new).and_return(service)
        allow(service).to receive(:authenticate).and_return({
          success: false,
          user: nil,
          errors: ['Authentication failed']
        })

        get :google_oauth2
        
        expect(response).to redirect_to(new_user_registration_url)
        expect(flash[:alert]).to eq('Authentication failed')
      end
    end
  end
end
