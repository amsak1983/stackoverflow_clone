require 'rails_helper'

RSpec.describe "Votes", type: :request do
  let(:user) { create(:user) }
  let(:author) { create(:user) }
  let(:question) { create(:question, user: author) }
  let(:answer) { create(:answer, question: question, user: author) }

  describe "POST /questions/:question_id/votes" do
    context "when user is authenticated" do
      before { sign_in user }

      context "when voting for a question" do
        it "creates an upvote" do
          expect {
            post question_votes_path(question), params: { value: 1 }, as: :json
          }.to change(Vote, :count).by(1)

          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)).to include(
            "rating" => 1,
            "user_vote" => 1
          )
        end

        it "creates a downvote" do
          expect {
            post question_votes_path(question), params: { value: -1 }, as: :json
          }.to change(Vote, :count).by(1)

          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)).to include(
            "rating" => -1,
            "user_vote" => -1
          )
        end

        it "returns error when trying to vote with the same value again" do
          post question_votes_path(question), params: { value: 1 }, as: :json

          expect {
            post question_votes_path(question), params: { value: 1 }, as: :json
          }.not_to change(Vote, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to include("error")
        end

        it "updates vote when voting with opposite value" do
          post question_votes_path(question), params: { value: 1 }, as: :json

          expect {
            post question_votes_path(question), params: { value: -1 }, as: :json
          }.not_to change(Vote, :count)

          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)).to include(
            "rating" => -1,
            "user_vote" => -1
          )
        end

        it "returns error when author tries to vote for own question" do
          sign_in author

          expect {
            post question_votes_path(question), params: { value: 1 }, as: :json
          }.not_to change(Vote, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to include("error")
        end

        it "returns error when value is invalid" do
          expect {
            post question_votes_path(question), params: { value: 2 }, as: :json
          }.not_to change(Vote, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to include("error")
        end
      end

      context "when voting for an answer" do
        it "creates an upvote" do
          expect {
            post answer_votes_path(answer), params: { value: 1 }, as: :json
          }.to change(Vote, :count).by(1)

          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)).to include(
            "rating" => 1,
            "user_vote" => 1
          )
        end
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized status" do
        post question_votes_path(question), params: { value: 1 }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /questions/:question_id/votes/:id" do
    context "when user is authenticated" do
      before { sign_in user }

      context "when canceling vote for a question" do
        it "removes the vote" do
          # First create a vote
          vote = create(:vote, user: user, votable: question, value: 1)

          expect {
            delete question_vote_path(question, vote), as: :json
          }.to change(Vote, :count).by(-1)

          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)).to include(
            "rating" => 0,
            "user_vote" => nil
          )
        end

        it "does nothing if user has not voted" do
          # Create a vote from another user
          other_user = create(:user)
          vote = create(:vote, user: other_user, votable: question, value: 1)

          expect {
            delete question_vote_path(question, vote), as: :json
          }.not_to change(Vote, :count)

          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)).to include(
            "rating" => 1,
            "user_vote" => nil
          )
        end
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized status" do
        vote = create(:vote, user: user, votable: question, value: 1)
        delete question_vote_path(question, vote), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /votes/:id" do
    context "when user is authenticated" do
      before { sign_in user }

      context "when canceling vote for an answer" do
        it "removes the vote" do
          # First create a vote
          vote = create(:vote, user: user, votable: answer, value: 1)

          expect {
            delete vote_path(vote, votable: 'answer', answer_id: answer.id), as: :json
          }.to change(Vote, :count).by(-1)

          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)).to include(
            "rating" => 0,
            "user_vote" => nil
          )
        end
      end
    end
  end
end
