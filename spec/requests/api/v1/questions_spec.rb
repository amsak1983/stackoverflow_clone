require 'rails_helper'

RSpec.describe 'API V1 Questions', type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:questions) { create_list(:question, 2, user: other_user) }

  describe 'GET /api/v1/questions' do
    include_examples 'oauth_protected_endpoint', http_method: :get, path_proc: -> { '/api/v1/questions' }

    it 'returns list of questions when authorized' do
      token = create_access_token_for(user)

      get '/api/v1/questions', headers: bearer_headers(token), as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.size).to eq(2)
      expect(json.first).to include('id', 'title', 'body')
    end
  end

  describe 'GET /api/v1/questions/:id' do
    include_examples 'oauth_protected_endpoint', http_method: :get, path_proc: -> { "/api/v1/questions/#{questions.first.id}" }

    it 'returns question when authorized' do
      token = create_access_token_for(user)

      get "/api/v1/questions/#{questions.first.id}", headers: bearer_headers(token), as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to include('id' => questions.first.id)
      expect(json).to include('title' => questions.first.title)
    end
  end

  describe 'POST /api/v1/questions' do
    include_examples 'oauth_protected_endpoint', http_method: :post, path_proc: -> { '/api/v1/questions' }

    let(:valid_params) { { question: { title: 'New title', body: 'New body' } } }
    let(:invalid_params) { { question: { title: '', body: '' } } }

    it 'creates a question with valid params' do
      token = create_access_token_for(user)

      expect {
        post '/api/v1/questions', params: valid_params, headers: bearer_headers(token), as: :json
      }.to change(Question, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json).to include('title' => 'New title')
    end

    it 'returns errors with invalid params' do
      token = create_access_token_for(user)

      expect {
        post '/api/v1/questions', params: invalid_params, headers: bearer_headers(token), as: :json
      }.not_to change(Question, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json).to include('errors')
    end
  end

  describe 'PATCH /api/v1/questions/:id' do
    include_examples 'oauth_protected_endpoint', http_method: :patch, path_proc: -> { "/api/v1/questions/#{questions.first.id}" }

    it 'updates own question' do
      own_question = create(:question, user: user)
      token = create_access_token_for(user)

      patch "/api/v1/questions/#{own_question.id}", params: { question: { title: 'Updated' } }, headers: bearer_headers(token), as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include('title' => 'Updated')
    end

    it 'forbids updating others question' do
      token = create_access_token_for(user)

      patch "/api/v1/questions/#{questions.first.id}", params: { question: { title: 'Hacker' } }, headers: bearer_headers(token), as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'DELETE /api/v1/questions/:id' do
    include_examples 'oauth_protected_endpoint', http_method: :delete, path_proc: -> { "/api/v1/questions/#{questions.last.id}" }

    it 'deletes own question' do
      own_question = create(:question, user: user)
      token = create_access_token_for(user)

      expect {
        delete "/api/v1/questions/#{own_question.id}", headers: bearer_headers(token), as: :json
      }.to change(Question, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'forbids deleting others question' do
      token = create_access_token_for(user)

      expect {
        delete "/api/v1/questions/#{questions.first.id}", headers: bearer_headers(token), as: :json
      }.not_to change(Question, :count)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
