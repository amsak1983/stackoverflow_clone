require 'rails_helper'

RSpec.describe "Votes", type: :request do
  let(:user) { create(:user) }
  let(:author) { create(:user) }
  let(:question) { create(:question, user: author) }
  let(:answer) { create(:answer, question: question, user: author) }

  describe 'Question votes' do
    let(:votable) { create(:question, user: author) }
    let(:vote) { create(:vote, votable: votable, user: user) }

    describe 'POST /questions/:question_id/votes/up' do
      context 'when user is authenticated' do
        before { sign_in(user) }

        it 'creates an upvote' do
          expect {
            post up_question_votes_path(votable)
          }.to change(Vote, :count).by(1)

          expect(response).to have_http_status(:success)
          expect(votable.votes.last.value).to eq(1)
        end
      end

      context 'when user is not authenticated' do
        it 'redirects to login page' do
          post up_question_votes_path(votable)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe 'POST /questions/:question_id/votes/down' do
      context 'when user is authenticated' do
        before { sign_in(user) }

        it 'creates a downvote' do
          expect {
            post down_question_votes_path(votable)
          }.to change(Vote, :count).by(1)

          expect(response).to have_http_status(:success)
          expect(votable.votes.last.value).to eq(-1)
        end
      end

      context 'when user is not authenticated' do
        it 'redirects to login page' do
          post down_question_votes_path(votable)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe 'DELETE /questions/:question_id/votes/:id' do
      context 'when user is authenticated' do
        before { sign_in(user) }

        it 'deletes the vote' do
          vote # создаем голос

          expect {
            delete question_vote_path(votable, vote)
          }.to change(Vote, :count).by(-1)

          expect(response).to have_http_status(:success)
        end
      end

      context 'when user is not authenticated' do
        it 'redirects to login page' do
          delete question_vote_path(votable, vote)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end

  describe 'Answer votes' do
    let(:votable) { create(:answer, question: question, user: author) }
    let(:vote) { create(:vote, votable: votable, user: user) }

    describe 'POST /answers/:answer_id/votes/up' do
      context 'when user is authenticated' do
        before { sign_in(user) }

        it 'creates an upvote' do
          expect {
            post up_answer_votes_path(votable)
          }.to change(Vote, :count).by(1)

          expect(response).to have_http_status(:success)
          expect(votable.votes.last.value).to eq(1)
        end
      end

      context 'when user is not authenticated' do
        it 'redirects to login page' do
          post up_answer_votes_path(votable)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe 'POST /answers/:answer_id/votes/down' do
      context 'when user is authenticated' do
        before { sign_in(user) }

        it 'creates a downvote' do
          expect {
            post down_answer_votes_path(votable)
          }.to change(Vote, :count).by(1)

          expect(response).to have_http_status(:success)
          expect(votable.votes.last.value).to eq(-1)
        end
      end

      context 'when user is not authenticated' do
        it 'redirects to login page' do
          post down_answer_votes_path(votable)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe 'DELETE /votes/:id' do
      context 'when user is authenticated' do
        before { sign_in(user) }

        it 'deletes the vote' do
          vote

          expect {
            delete vote_path(vote, votable: 'answer', answer_id: votable.id)
          }.to change(Vote, :count).by(-1)

          expect(response).to have_http_status(:success)
        end
      end

      context 'when user is not authenticated' do
        it 'redirects to login page' do
          delete vote_path(vote, votable: 'answer', answer_id: votable.id)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end
end
