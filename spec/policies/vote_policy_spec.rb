require 'rails_helper'
require_relative 'policy_spec_helper'

RSpec.describe VotePolicy, type: :policy do
  let(:user) { create(:user) }
  let(:author) { create(:user) }
  let(:question) { create(:question, user: author) }
  let(:answer) { create(:answer, user: author) }

  describe 'voting permissions' do
    it 'allows non-authors to vote' do
      expect(VotePolicy.new(user, question)).to permit_action(:vote)
      expect(VotePolicy.new(user, question)).to permit_action(:up)
      expect(VotePolicy.new(user, question)).to permit_action(:down)
      expect(VotePolicy.new(user, answer)).to permit_action(:vote)
    end

    it 'denies authors from voting on own content' do
      expect(VotePolicy.new(author, question)).not_to permit_action(:vote)
      expect(VotePolicy.new(author, question)).not_to permit_action(:up)
      expect(VotePolicy.new(author, answer)).not_to permit_action(:down)
    end

    it 'denies guests from voting' do
      expect(VotePolicy.new(nil, question)).not_to permit_action(:vote)
    end
  end

  describe 'vote destruction' do
    let(:vote) { create(:vote, user: user, votable: question) }

    it 'allows vote owners to destroy their votes' do
      expect(VotePolicy.new(user, vote)).to permit_action(:destroy)
    end

    it 'denies non-owners from destroying votes' do
      expect(VotePolicy.new(author, vote)).not_to permit_action(:destroy)
    end

    it 'denies guests from destroying votes' do
      expect(VotePolicy.new(nil, vote)).not_to permit_action(:destroy)
    end
  end
end
