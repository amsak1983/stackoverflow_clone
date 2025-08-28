require 'rails_helper'
require_relative 'policy_spec_helper'

RSpec.describe CommentPolicy, type: :policy do
  subject { described_class.new(user, comment) }

  let(:commentable) { create(:question) }
  let(:comment) { create(:comment, commentable: commentable) }

  context "for a visitor" do
    let(:user) { nil }

    it_behaves_like "denies action", :create
    it_behaves_like "denies action", :destroy
  end

  context "for a user who doesn't own the comment" do
    let(:user) { create(:user) }

    it_behaves_like "permits action", :create
    it_behaves_like "denies action", :destroy
  end

  context "for the comment author" do
    let(:user) { comment.user }

    it_behaves_like "permits action", :create
    it_behaves_like "permits action", :destroy
  end

  describe "Scope" do
    subject { described_class::Scope.new(user, Comment.all) }

    let(:user) { create(:user) }
    let!(:comments) { create_list(:comment, 3) }

    it "returns all comments" do
      expect(subject.resolve).to match_array(comments)
    end
  end
end
