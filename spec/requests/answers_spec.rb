require 'rails_helper'

RSpec.describe 'Answers', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:answer) { create(:answer, question: question, user: user, body: 'Original answer') }

  describe 'POST /questions/:question_id/answers' do
    context 'when user is signed in' do
      before { sign_in_user user }

      context 'with valid parameters' do
        let(:valid_params) { { answer: { body: 'This is a valid answer' } } }

        it 'creates a new answer' do
          expect {
            post question_answers_path(question), params: valid_params, as: :turbo_stream
          }.to change(Answer, :count).by(1)
        end

        it 'returns turbo stream response' do
          post question_answers_path(question), params: valid_params, as: :turbo_stream
          expect(response.content_type).to include('text/vnd.turbo-stream.html')
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) { { answer: { body: '' } } }

        it 'does not create a new answer' do
          expect {
            post question_answers_path(question), params: invalid_params, as: :turbo_stream
          }.not_to change(Answer, :count)
        end

        it 'returns turbo stream response with errors' do
          post question_answers_path(question), params: invalid_params, as: :turbo_stream
          expect(response.content_type).to include('text/vnd.turbo-stream.html')
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        post question_answers_path(question), params: { answer: { body: 'Test' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /answers/:id' do
    context 'when user is the author' do
      before { sign_in_user user }

      it 'updates the answer' do
        patch answer_path(answer), params: { answer: { body: 'Updated answer' } }, as: :turbo_stream
        expect(answer.reload.body).to eq('Updated answer')
      end

      it 'returns turbo stream response' do
        patch answer_path(answer), params: { answer: { body: 'Updated answer' } }, as: :turbo_stream
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
      end
    end

    context 'when user is not the author' do
      before { sign_in other_user }

      it 'redirects with alert' do
        patch answer_path(answer), params: { answer: { body: 'Updated answer' } }
        expect(response).to redirect_to(answer.question)
        expect(flash[:alert]).to eq('You can only edit your own answers')
      end
    end
  end

  describe 'DELETE /answers/:id' do
    context 'when user is the author' do
      before { sign_in_user user }

      it 'deletes the answer' do
        answer # create the answer
        expect {
          delete answer_path(answer), as: :turbo_stream
        }.to change(Answer, :count).by(-1)
      end

      it 'returns turbo stream response' do
        delete answer_path(answer), as: :turbo_stream
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
      end
    end

    context 'when user is not the author' do
      before { sign_in other_user }

      it 'redirects with alert' do
        delete answer_path(answer)
        expect(response).to redirect_to(answer.question)
        expect(flash[:alert]).to eq('You can only edit your own answers')
      end
    end
  end

  describe 'PATCH /answers/:id/mark_as_best' do
    context 'when user is the question author' do
      before { sign_in_user user }

      it 'marks the answer as best' do
        patch mark_as_best_answer_path(answer), as: :turbo_stream
        expect(answer.reload.best).to be true
      end

      it 'unmarks other answers as best' do
        other_answer = create(:answer, question: question, user: other_user, best: true)
        patch mark_as_best_answer_path(answer), as: :turbo_stream
        expect(other_answer.reload.best).to be false
        expect(answer.reload.best).to be true
      end

      it 'returns turbo stream response' do
        patch mark_as_best_answer_path(answer), as: :turbo_stream
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
      end
    end

    context 'when user is not the question author' do
      before { sign_in other_user }

      it 'redirects with alert' do
        patch mark_as_best_answer_path(answer)
        expect(response).to redirect_to(answer.question)
        expect(flash[:alert]).to eq('Only the question author can mark answers as best')
      end
    end
  end

  describe 'GET /answers/:id/edit' do
    context 'when user is the author' do
      before { sign_in_user user }

      it 'returns turbo stream with edit form' do
        get edit_answer_path(answer), as: :turbo_stream
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
      end
    end

    context 'when user is not the author' do
      before { sign_in other_user }

      it 'redirects to the question and sets flash alert' do
        get edit_answer_path(answer)
        expect(response).to redirect_to(question_path(answer.question))
        expect(session['flash']['flashes']['alert']).to eq('You can only edit your own answers')
      end
    end
  end
end
