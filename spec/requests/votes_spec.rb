require 'rails_helper'

RSpec.describe "Votes", type: :request do
  let(:user) { create(:user) }
  let(:author) { create(:user) }
  let(:question) { create(:question, user: author) }
  let(:answer) { create(:answer, question: question, user: author) }

  describe 'Question votes' do
    include_examples 'votable endpoints',
      up_path: ->(votable) { up_question_votes_path(votable) },
      down_path: ->(votable) { down_question_votes_path(votable) },
      delete_path: ->(votable, vote) { question_vote_path(votable, vote) },
      build_votable: -> { create(:question, user: author) }
  end

  describe 'Answer votes' do
    include_examples 'votable endpoints',
      up_path: ->(votable) { up_answer_votes_path(votable) },
      down_path: ->(votable) { down_answer_votes_path(votable) },
      delete_path: ->(votable, vote) { vote_path(vote, votable: 'answer', answer_id: votable.id) },
      build_votable: -> { create(:answer, question: question, user: author) }
  end
end
