require 'rails_helper'

RSpec.describe "Answers", type: :request do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }

  describe 'POST /questions/:question_id/answers' do
    context 'when user is authenticated' do
      before { sign_in user }

      context 'with valid attributes' do
        let(:valid_params) { { answer: attributes_for(:answer) } }

        it 'saves a new answer in the database' do
          expect { post question_answers_path(question), params: valid_params }.to change(Answer, :count).by(1)
        end

        it 'assigns current user to the answer' do
          post question_answers_path(question), params: valid_params
          expect(Answer.last.user).to eq user
        end

        it 'redirects to the question' do
          post question_answers_path(question), params: valid_params
          expect(response).to redirect_to question_path(question)
        end
      end

      context 'with invalid attributes' do
        let(:invalid_params) { { answer: attributes_for(:answer, :invalid) } }

        it 'does not save the answer' do
          expect { post question_answers_path(question), params: invalid_params }.not_to change(Answer, :count)
        end

        it 're-renders the question show template' do
          post question_answers_path(question), params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'does not save the answer' do
        expect do
          post question_answers_path(question), params: { answer: attributes_for(:answer) }
        end.not_to change(Answer, :count)
      end

      it 'redirects to the sign-in page' do
        post question_answers_path(question), params: { answer: attributes_for(:answer) }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE /answers/:id' do
    let!(:answer) { create(:answer, question: question, user: user) }

    context 'when user is authenticated' do
      before { sign_in user }

      context 'when user is the author' do
        it 'deletes the answer' do
          expect { delete answer_path(answer) }.to change(Answer, :count).by(-1)
        end

        it 'redirects to the question' do
          delete answer_path(answer)
          expect(response).to redirect_to question_path(question)
        end
      end

      context 'when user is not the author' do
        let(:other_user) { create(:user) }
        let!(:other_answer) { create(:answer, question: question, user: other_user) }

        it 'does not delete the answer' do
          expect { delete answer_path(other_answer) }.not_to change(Answer, :count)
        end

        it 'redirects to the question' do
          delete answer_path(other_answer)
          expect(response).to redirect_to question_path(question)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'does not delete the answer' do
        expect { delete answer_path(answer) }.not_to change(Answer, :count)
      end

      it 'redirects to the sign-in page' do
        delete answer_path(answer)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
