require 'rails_helper'

RSpec.describe "Questions", type: :request do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }

  describe 'GET /questions' do
    it 'returns http success' do
      get questions_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /questions/:id' do
    it 'returns http success' do
      get question_path(question)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /questions/new' do
    context 'when user is authenticated' do
      before { sign_in user }

      it 'returns http success' do
        get new_question_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to the sign-in page' do
        get new_question_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /questions' do
    context 'when user is authenticated' do
      before { sign_in user }

      context 'with valid attributes' do
        let(:valid_params) { { question: attributes_for(:question) } }

        it 'saves the new question in the database' do
          expect { post questions_path, params: valid_params }.to change(Question, :count).by(1)
        end

        it 'assigns current user to question' do
          post questions_path, params: valid_params
          expect(Question.last.user).to eq user
        end

        it 'redirects to the new question' do
          post questions_path, params: valid_params
          expect(response).to redirect_to(question_path(Question.last))
        end
      end

      context 'with invalid attributes' do
        let(:invalid_params) { { question: attributes_for(:question, :invalid) } }

        it 'does not save the question' do
          expect { post questions_path, params: invalid_params }.not_to change(Question, :count)
        end

        it 're-renders the :new template' do
          post questions_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'does not save the question' do
        expect { post questions_path, params: { question: attributes_for(:question) } }.not_to change(Question, :count)
      end

      it 'redirects to the sign-in page' do
        post questions_path, params: { question: attributes_for(:question) }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /questions/:id' do
    let(:update_params) { { question: { title: 'Updated title', body: 'Updated body' } } }

    context 'when user is authenticated' do
      before { sign_in user }

      context 'when user is the author' do
        it 'updates the question' do
          patch question_path(question, format: :turbo_stream), params: update_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          question.reload
          expect(question.title).to eq('Updated title')
          expect(question.body).to eq('Updated body')
        end

        it 'returns turbo stream response' do
          patch question_path(question, format: :turbo_stream), params: update_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include('text/vnd.turbo-stream.html')
        end
      end

      context 'with invalid attributes' do
        let(:invalid_params) { { question: { title: '', body: '' } } }

        it 'does not update the question' do
          patch question_path(question, format: :turbo_stream), params: invalid_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          expect(question.reload.title).not_to eq('')
        end

        it 'returns unprocessable_content status' do
          patch question_path(question, format: :turbo_stream), params: invalid_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context 'when user is not the author' do
        let(:other_user) { create(:user) }
        let!(:other_question) { create(:question, user: other_user) }

        it 'does not update the question' do
          patch question_path(other_question, format: :turbo_stream), params: update_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          expect(other_question.reload.title).not_to eq('Updated title')
        end

        it 'returns forbidden status' do
          patch question_path(other_question, format: :turbo_stream), params: update_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'does not update the question' do
        expect {
          patch question_path(question), params: update_params, xhr: true
        }.not_to change { question.reload.attributes }
      end

      it 'returns unauthorized status' do
        patch question_path(question), params: update_params, xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /questions/:id' do
    let!(:question_to_delete) { create(:question, user: user) }

    context 'when user is authenticated' do
      before { sign_in user }

      context 'when user is the author' do
        it 'deletes the question' do
          expect { delete question_path(question_to_delete) }.to change(Question, :count).by(-1)
        end

        it 'redirects to the questions index' do
          delete question_path(question_to_delete)
          expect(response).to redirect_to questions_path
        end
      end

      context 'when user is not the author' do
        let(:other_user) { create(:user) }
        let!(:other_question) { create(:question, user: other_user) }

        it 'does not delete the question' do
          expect { delete question_path(other_question) }.not_to change(Question, :count)
        end

        it 'returns forbidden status' do
          delete question_path(other_question)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(root_path)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'does not delete the question' do
        expect { delete question_path(question_to_delete) }.not_to change(Question, :count)
      end

      it 'redirects to the sign-in page' do
        delete question_path(question_to_delete)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
