require 'rails_helper'

RSpec.describe 'Links', type: :request do
  let!(:user) { create(:user) }
  let!(:question) { create(:question, user: user) }
  let!(:link) { create(:link, linkable: question) }

  describe 'DELETE /links/:id' do
    context 'when user is the author' do
      before { sign_in user }

      it 'destroys the link' do
        expect {
          delete link_path(link), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.to change(Link, :count).by(-1)
      end

      it 'returns turbo stream response' do
        delete link_path(link), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
      end
    end

    context 'when user is not the author' do
      let(:other_user) { create(:user) }
      before { sign_in other_user }

      it 'returns forbidden status' do
        delete link_path(link), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in' do
        delete link_path(link)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
