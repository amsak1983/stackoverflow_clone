require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
  let(:user) { create(:user, confirmed_at: Time.current) }
  let(:other_user) { create(:user, confirmed_at: Time.current) }
  let(:question) { create(:question, user: user) }

  describe 'POST #create' do
    context 'when unauthenticated' do
      it 'redirects to sign in' do
        post :create, params: { question_id: question.id }
        expect(response).to have_http_status(302)
      end
    end

    context 'when authenticated' do
      before do
        question.subscriptions.find_or_create_by!(user: user)
      end
      it 'creates subscription for current user (who is not the author)' do
        sign_in other_user
        expect {
          post :create, params: { question_id: question.id }
        }.to change(Subscription, :count).by(1)
        expect(response).to redirect_to(question)
        expect(flash[:notice]).to eq('You are subscribed to question updates')
      end

      it 'does not duplicate subscription if already exists' do
        question.subscriptions.find_or_create_by!(user: user)
        sign_in user
        expect {
          post :create, params: { question_id: question.id }
        }.not_to change(Subscription, :count)
        expect(response).to redirect_to(question)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:subscription) do
      question.subscriptions.find_by(user: user) || create(:subscription, user: user, question: question)
    end

    context 'when unauthenticated' do
      it 'redirects to sign in' do
        delete :destroy, params: { id: subscription.id }
        expect(response).to have_http_status(302)
      end
    end

    context 'when authenticated' do
      it 'allows owner to unsubscribe' do
        sign_in user
        expect {
          delete :destroy, params: { id: subscription.id }
        }.to change(Subscription, :count).by(-1)
        expect(response).to redirect_to(question)
        expect(flash[:notice]).to eq('You have unsubscribed from question updates')
      end

      it 'prevents other users from deleting someone else subscription' do
        sign_in other_user
        expect {
          delete :destroy, params: { id: subscription.id }
        }.not_to change(Subscription, :count)
        expect(response).to redirect_to(question)
        expect(flash[:alert]).to eq('You can only unsubscribe from your own subscriptions')
      end
    end
  end
end
