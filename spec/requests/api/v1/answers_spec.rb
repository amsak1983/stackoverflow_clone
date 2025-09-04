require 'rails_helper'

RSpec.describe 'API V1 Answers', type: :request do
  let!(:user) { create(:user) }
  let!(:author) { create(:user) }
  let!(:question) { create(:question, user: author) }
  let!(:answers) { create_list(:answer, 2, question: question, user: author) }

  describe 'GET /api/v1/questions/:question_id/answers' do
    include_examples 'oauth_protected_endpoint', http_method: :get, path_proc: -> { "/api/v1/questions/#{question.id}/answers" }

    it 'returns list of answers for question when authorized' do
      token = create_access_token_for(user)

      get "/api/v1/questions/#{question.id}/answers", headers: bearer_headers(token), as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.size).to eq(2)
      expect(json.first).to include('id', 'body', 'question_id')
    end
  end

  describe 'GET /api/v1/answers/:id' do
    include_examples 'oauth_protected_endpoint', http_method: :get, path_proc: -> { "/api/v1/answers/#{answers.first.id}" }

    it 'returns answer when authorized' do
      token = create_access_token_for(user)

      get "/api/v1/answers/#{answers.first.id}", headers: bearer_headers(token), as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to include('id' => answers.first.id)
      expect(json).to include('body' => answers.first.body)
    end
  end

  describe 'POST /api/v1/questions/:question_id/answers' do
    include_examples 'oauth_protected_endpoint', http_method: :post, path_proc: -> { "/api/v1/questions/#{question.id}/answers" }

    let(:valid_params) { { answer: { body: 'New answer' } } }
    let(:invalid_params) { { answer: { body: '' } } }

    it 'creates an answer with valid params' do
      token = create_access_token_for(user)

      expect {
        post "/api/v1/questions/#{question.id}/answers", params: valid_params, headers: bearer_headers(token), as: :json
      }.to change(Answer, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json).to include('body' => 'New answer')
      expect(json['question_id']).to eq(question.id)
    end

    it 'returns errors with invalid params' do
      token = create_access_token_for(user)

      expect {
        post "/api/v1/questions/#{question.id}/answers", params: invalid_params, headers: bearer_headers(token), as: :json
      }.not_to change(Answer, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json).to include('errors')
    end
  end

  describe 'PATCH /api/v1/answers/:id' do
    include_examples 'oauth_protected_endpoint', http_method: :patch, path_proc: -> { "/api/v1/answers/#{answers.first.id}" }

    it 'updates own answer' do
      own_answer = create(:answer, question: question, user: user)
      token = create_access_token_for(user)

      patch "/api/v1/answers/#{own_answer.id}", params: { answer: { body: 'Updated' } }, headers: bearer_headers(token), as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include('body' => 'Updated')
    end

    it 'forbids updating others answer' do
      token = create_access_token_for(user)

      patch "/api/v1/answers/#{answers.first.id}", params: { answer: { body: 'Hacker' } }, headers: bearer_headers(token), as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'DELETE /api/v1/answers/:id' do
    include_examples 'oauth_protected_endpoint', http_method: :delete, path_proc: -> { "/api/v1/answers/#{answers.last.id}" }

    it 'deletes own answer' do
      own_answer = create(:answer, question: question, user: user)
      token = create_access_token_for(user)

      expect {
        delete "/api/v1/answers/#{own_answer.id}", headers: bearer_headers(token), as: :json
      }.to change(Answer, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'forbids deleting others answer' do
      token = create_access_token_for(user)

      expect {
        delete "/api/v1/answers/#{answers.first.id}", headers: bearer_headers(token), as: :json
      }.not_to change(Answer, :count)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
