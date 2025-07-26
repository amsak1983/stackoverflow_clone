require 'rails_helper'

RSpec.describe "Answers", type: :request do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:answer) { create(:answer, question: question, user: user) }

  describe 'POST /questions/:question_id/answers' do
    let(:valid_params) { { answer: attributes_for(:answer) } }
    let(:invalid_params) { { answer: attributes_for(:answer, :invalid) } }

    context 'when user is authenticated' do
      before { sign_in user }

      context 'with valid attributes' do
        it 'saves a new answer in the database' do
          expect { 
            post question_answers_path(question), params: valid_params, xhr: true 
          }.to change(Answer, :count).by(1)
        end

        it 'assigns current user to the answer' do
          post question_answers_path(question), params: valid_params, xhr: true
          expect(Answer.last.user).to eq user
        end

        it 'returns turbo stream response' do
          post question_answers_path(question, format: :turbo_stream), params: valid_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include('text/vnd.turbo-stream.html')
        end
      end

      context 'with invalid attributes' do
        it 'does not save the answer' do
          expect { 
            post question_answers_path(question), params: invalid_params, xhr: true 
          }.not_to change(Answer, :count)
        end

        it 'returns unprocessable_entity status' do
          post question_answers_path(question), params: invalid_params, xhr: true
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'does not save the answer' do
        expect {
          post question_answers_path(question), params: valid_params, xhr: true
        }.not_to change(Answer, :count)
      end

      it 'returns unauthorized status' do
        post question_answers_path(question), params: valid_params, xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /answers/:id' do
    let(:update_params) { { answer: { body: 'Updated answer' } } }

    context 'when user is authenticated' do
      before { sign_in user }

      context 'when user is the author' do
        it 'updates the answer' do
          patch answer_path(answer), params: update_params, xhr: true
          expect(answer.reload.body).to eq('Updated answer')
        end

        it 'returns turbo stream response' do
          patch answer_path(answer, format: :turbo_stream), params: update_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include('text/vnd.turbo-stream.html')
        end
      end

      context 'when user is not the author' do
        let(:other_user) { create(:user) }
        let!(:other_answer) { create(:answer, question: question, user: other_user) }

        it 'does not update the answer' do
          expect {
            patch answer_path(other_answer, format: :turbo_stream), params: update_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          }.not_to change { other_answer.reload.body }
        end

        it 'returns forbidden status' do
          patch answer_path(other_answer, format: :turbo_stream), params: update_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'does not update the answer' do
        expect {
          patch answer_path(answer, format: :turbo_stream), params: update_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.not_to change { answer.reload.body }
      end

      it 'returns unauthorized status' do
        patch answer_path(answer, format: :turbo_stream), params: update_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe 'DELETE /answers/:id' do
    let!(:answer) { create(:answer, question: question, user: user) }

    context 'when user is authenticated' do
      before { sign_in user }

      context 'when user is the author' do
        it 'deletes the answer' do
          expect { 
            delete answer_path(answer, format: :turbo_stream), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          }.to change(Answer, :count).by(-1)
        end

        it 'returns turbo stream response' do
          delete answer_path(answer, format: :turbo_stream), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include('text/vnd.turbo-stream.html')
        end
      end

      context 'when user is not the author' do
        let(:other_user) { create(:user) }
        let!(:other_answer) { create(:answer, question: question, user: other_user) }

        it 'does not delete the answer' do
          expect { 
            delete answer_path(other_answer, format: :turbo_stream), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          }.not_to change(Answer, :count)
        end

        it 'returns forbidden status' do
          delete answer_path(other_answer, format: :turbo_stream), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'does not delete the answer' do
        expect { 
          delete answer_path(answer, format: :turbo_stream), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.not_to change(Answer, :count)
      end

      it 'returns unauthorized status' do
        delete answer_path(answer, format: :turbo_stream), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe 'PATCH /answers/:id/set_best' do
    let(:question) { create(:question) }
    let!(:answer) { create(:answer, question: question) }
    let(:question_owner) { question.user }

    context 'when user is authenticated' do
      context 'when user is the question author' do
        before { sign_in question_owner }

        context 'when answer is not the best' do
          it 'sets the answer as best' do
            patch set_best_answer_path(answer, format: :turbo_stream), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
            expect(answer.reload.best).to be_truthy
          end

          it 'returns turbo stream response' do
            patch set_best_answer_path(answer, format: :turbo_stream), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
            expect(response).to have_http_status(:ok)
            expect(response.content_type).to include('text/vnd.turbo-stream.html')
          end
        end

        context 'when another answer is already the best' do
          let!(:best_answer) { create(:answer, question: question, best: true) }

          it 'sets the new answer as best' do
            patch set_best_answer_path(answer), xhr: true
            expect(answer.reload.best).to be_truthy
          end

          it 'unsets the previous best answer' do
            patch set_best_answer_path(answer), xhr: true
            expect(best_answer.reload.best).to be_falsey
          end
        end
      end

      context 'when user is not the question author' do
        before { sign_in user }

        it 'does not change the best answer' do
          expect {
            patch set_best_answer_path(answer, format: :turbo_stream), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          }.not_to change { answer.reload.best }
        end

        it 'returns forbidden status' do
          patch set_best_answer_path(answer, format: :turbo_stream), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'does not change the best answer' do
        expect {
          patch set_best_answer_path(answer), xhr: true
        }.not_to change { answer.reload.best }
      end

      it 'returns unauthorized status' do
        patch set_best_answer_path(answer), xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
