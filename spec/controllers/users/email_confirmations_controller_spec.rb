require 'rails_helper'

RSpec.describe Users::EmailConfirmationsController, type: :controller do
  let(:user) { create(:user, confirmed_at: nil, provider: 'telegram', uid: '123456') }

  describe '#new' do
    context 'when oauth user is in session' do
      before do
        session[:oauth_user_id] = user.id
      end

      it 'renders new template' do
        get :new
        expect(response).to render_template(:new)
        expect(assigns(:user)).to eq(user)
      end
    end

    context 'when no oauth user in session' do
      it 'redirects to root with error' do
        get :new
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Session expired")
      end
    end
  end

  describe '#create' do
    before do
      session[:oauth_user_id] = user.id
    end

    context 'with valid email' do
      let(:valid_params) { { user: { unconfirmed_email: 'new@example.com' } } }

      it 'updates user email and sends confirmation' do
        expect(UserMailer).to receive(:email_confirmation).with(user).and_call_original
        expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now)

        post :create, params: valid_params

        user.reload
        expect(user.unconfirmed_email).to eq('new@example.com')
        expect(user.confirmation_token).to be_present
        expect(user.confirmation_sent_at).to be_present

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Confirmation email sent to new@example.com")
      end
    end

    context 'with invalid email' do
      let(:invalid_params) { { user: { unconfirmed_email: 'invalid-email' } } }

      it 'renders new template with errors' do
        allow(UserMailer).to receive(:email_confirmation).and_return(double(deliver_now: true))
        post :create, params: invalid_params
        expect(response).to render_template(:new)
        expect(response.status).to eq(422)
      end
    end
  end

  describe '#confirm' do
    let(:confirmation_token) { 'valid_token' }

    before do
      user.update!(
        unconfirmed_email: 'confirmed@example.com',
        confirmation_token: confirmation_token,
        confirmation_sent_at: Time.current
      )
    end

    context 'with valid token' do
      it 'confirms user email and signs them in' do
        get :confirm, params: { id: user.id, confirmation_token: confirmation_token }

        user.reload
        expect(user.email).to eq('confirmed@example.com')
        expect(user.unconfirmed_email).to be_nil
        expect(user.confirmation_token).to be_nil
        expect(user.confirmation_sent_at).to be_nil
        expect(user).to be_email_verified

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Email successfully confirmed! Welcome!")
        expect(controller.current_user).to eq(user)
      end
    end

    context 'with invalid token' do
      it 'redirects with error' do
        get :confirm, params: { id: user.id, confirmation_token: 'invalid_token' }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Invalid or expired confirmation link")
      end
    end

    context 'with expired token' do
      before do
        user.update!(confirmation_sent_at: 4.days.ago)
      end

      it 'redirects with error' do
        get :confirm, params: { id: user.id, confirmation_token: confirmation_token }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Invalid or expired confirmation link")
      end
    end
  end
end
