require 'rails_helper'

shared_examples_for 'votable' do
  let(:model) { described_class.to_s.underscore.to_sym }
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:votable) { create(model) }
  let(:user_votable) { create(model, user: user) }

  describe '#vote_by' do
    context 'when user is not the author' do
      it 'creates a new vote with value 1' do
        expect { votable.vote_by(user, 1) }.to change(Vote, :count).by(1)
        expect(votable.votes.last.value).to eq(1)
      end

      it 'creates a new vote with value -1' do
        expect { votable.vote_by(user, -1) }.to change(Vote, :count).by(1)
        expect(votable.votes.last.value).to eq(-1)
      end

      it 'updates existing vote to opposite value' do
        votable.vote_by(user, 1)
        expect { votable.vote_by(user, -1) }.not_to change(Vote, :count)
        expect(votable.votes.last.value).to eq(-1)
      end

      it 'returns false when trying to vote with same value again' do
        votable.vote_by(user, 1)
        expect(votable.vote_by(user, 1)).to be_falsey
      end
    end

    context 'when user is the author' do
      it 'does not create a vote' do
        expect { user_votable.vote_by(user, 1) }.not_to change(Vote, :count)
      end

      it 'returns false' do
        expect(user_votable.vote_by(user, 1)).to be_falsey
      end
    end
  end

  describe '#cancel_vote_by' do
    it 'removes user vote' do
      votable.vote_by(user, 1)
      expect { votable.cancel_vote_by(user) }.to change(Vote, :count).by(-1)
    end

    it 'does nothing if user has not voted' do
      expect { votable.cancel_vote_by(user) }.not_to change(Vote, :count)
    end
  end

  describe '#rating' do
    before do
      votable.vote_by(user, 1)
      votable.vote_by(another_user, -1)
    end

    it 'returns sum of all votes' do
      expect(votable.rating).to eq(0)
    end

    it 'changes when votes change' do
      votable.vote_by(create(:user), 1)
      expect(votable.rating).to eq(1)
    end
  end

  describe '#voted_by?' do
    it 'returns true if user has voted' do
      votable.vote_by(user, 1)
      expect(votable.voted_by?(user)).to be_truthy
    end

    it 'returns false if user has not voted' do
      expect(votable.voted_by?(user)).to be_falsey
    end
  end

  describe '#vote_value_by' do
    it 'returns vote value for user' do
      votable.vote_by(user, 1)
      expect(votable.vote_value_by(user)).to eq(1)
    end

    it 'returns nil if user has not voted' do
      expect(votable.vote_value_by(user)).to be_nil
    end
  end
end
