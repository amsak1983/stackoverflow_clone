require 'rails_helper'

RSpec.describe Vote, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:votable) }
  end

  describe 'validations' do
    it { should validate_presence_of(:value) }
    it { should validate_inclusion_of(:value).in_array([ -1, 1 ]) }

    it 'validates uniqueness of user_id scoped to votable_id and votable_type' do
      create(:vote, :for_question)
      should validate_uniqueness_of(:user_id).scoped_to([ :votable_id, :votable_type ])
    end
  end

  describe 'scopes' do
    let!(:question) { create(:question) }
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:upvote) { create(:vote, votable: question, user: user1, value: 1) }
    let!(:downvote) { create(:vote, votable: question, user: user2, value: -1) }

    it 'upvotes returns only votes with value 1' do
      expect(Vote.upvotes).to contain_exactly(upvote)
    end

    it 'downvotes returns only votes with value -1' do
      expect(Vote.downvotes).to contain_exactly(downvote)
    end
  end
end
