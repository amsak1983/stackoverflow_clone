require 'rails_helper'

RSpec.describe "Questions", type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:question) }
  let(:invalid_attributes) { attributes_for(:question, title: nil, body: nil) }

  before { sign_in_user user }

  describe 'GET /questions/new' do
    it 'returns http success' do
      get new_question_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /questions' do
    context 'with valid parameters' do
      it 'creates a new Question' do
        expect {
          post questions_path, params: { question: valid_attributes }
        }.to change(Question, :count).by(1)
      end

      it 'redirects to the created question' do
        post questions_path, params: { question: valid_attributes }
        expect(response).to redirect_to(question_path(Question.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Question' do
        expect {
          post questions_path, params: { question: invalid_attributes }
        }.to change(Question, :count).by(0)
      end

      it 'renders the new template with unprocessable_entity status' do
        post questions_path, params: { question: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /questions/:id' do
    let!(:question) { create(:question, user: user) }

    it 'returns http success' do
      get question_path(question)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /questions/:id/edit' do
    let!(:question) { create(:question, user: user) }

    it 'returns http success' do
      get edit_question_path(question)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /questions/:id' do
    let!(:question) { create(:question, user: user) }
    let(:new_attributes) { { title: 'Updated Title', body: 'Updated body' } }

    context 'with valid parameters' do
      it 'updates the requested question' do
        patch question_path(question), params: { question: new_attributes }
        question.reload
        expect(question.title).to eq('Updated Title')
        expect(question.body).to eq('Updated body')
      end

      it 'redirects to the question' do
        patch question_path(question), params: { question: new_attributes }
        expect(response).to redirect_to(question_path(question))
      end
    end

    context 'with invalid parameters' do
      it 'renders the edit template with unprocessable_entity status' do
        patch question_path(question), params: { question: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /questions/:id' do
    let!(:question) { create(:question, user: user) }

    it 'destroys the requested question' do
      expect {
        delete question_path(question)
      }.to change(Question, :count).by(-1)
    end

    it 'redirects to the questions list' do
      delete question_path(question)
      expect(response).to redirect_to(questions_path)
    end
  end
end
