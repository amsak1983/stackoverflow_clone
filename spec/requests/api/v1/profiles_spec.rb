require 'rails_helper'

RSpec.describe 'API V1 Profiles', type: :request do
  let!(:user) { create(:user) }
  let!(:other_users) { create_list(:user, 2) }

  describe 'GET /api/v1/profiles/me' do
    include_examples 'oauth_protected_endpoint', http_method: :get, path_proc: -> { '/api/v1/profiles/me' }

    it 'returns current user when authorized' do
      token = create_access_token_for(user)

      get '/api/v1/profiles/me', headers: bearer_headers(token), as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to include('id' => user.id)
      expect(json).to include('email' => user.email)
    end
  end

  describe 'GET /api/v1/profiles' do
    include_examples 'oauth_protected_endpoint', http_method: :get, path_proc: -> { '/api/v1/profiles' }

    it 'returns other users excluding current when authorized' do
      token = create_access_token_for(user)

      get '/api/v1/profiles', headers: bearer_headers(token), as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      ids = json.map { |u| u['id'] }
      expect(ids).to match_array(other_users.map(&:id))
      expect(ids).not_to include(user.id)
    end
  end
end
