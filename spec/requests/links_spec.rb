require 'rails_helper'

RSpec.describe 'Links', type: :request do
  describe 'DELETE /links/:id' do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }
    let(:question) { create(:question, user: user) }
    let!(:link) { create(:link, linkable: question) }

    context 'when user is authenticated' do
      context 'and is the author of the linkable' do
        before { sign_in(user) }

        it 'deletes the link' do
          expect do
            delete link_path(link), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          end.to change(Link, :count).by(-1)
        end

        it 'returns turbo stream response' do
          delete link_path(link), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
        end
      end

      context 'and is not the author of the linkable' do
        before { sign_in(another_user) }

        it 'does not delete the link' do
          expect do
            delete link_path(link), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          end.not_to change(Link, :count)
        end

        it 'returns forbidden status' do
          delete link_path(link), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'does not delete the link' do
        expect do
          delete link_path(link)
        end.not_to change(Link, :count)
      end

      it 'redirects to login page' do
        delete link_path(link)
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
