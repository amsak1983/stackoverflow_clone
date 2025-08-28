require 'rails_helper'
require_relative 'policy_spec_helper'

RSpec.describe QuestionPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:author) { create(:user) }
  let(:question) { create(:question, user: author) }

  it 'allows everyone to view questions' do
    expect(QuestionPolicy.new(user, question)).to permit_action(:show)
    expect(QuestionPolicy.new(nil, question)).to permit_action(:show)
  end

  it 'allows authenticated users to create questions' do
    expect(QuestionPolicy.new(user, Question.new)).to permit_action(:create)
  end

  it 'denies guests from creating questions' do
    expect(QuestionPolicy.new(nil, Question.new)).not_to permit_action(:create)
  end

  it 'allows authors to manage their questions' do
    expect(QuestionPolicy.new(author, question)).to permit_action(:update)
    expect(QuestionPolicy.new(author, question)).to permit_action(:destroy)
  end

  it 'denies non-authors from managing questions' do
    expect(QuestionPolicy.new(user, question)).not_to permit_action(:update)
    expect(QuestionPolicy.new(user, question)).not_to permit_action(:destroy)
    expect(QuestionPolicy.new(nil, question)).not_to permit_action(:update)
  end

  describe "Scope" do
    let!(:questions) { create_list(:question, 3) }

    it "returns all questions for any user" do
      expect(QuestionPolicy::Scope.new(user, Question.all).resolve).to match_array(questions)
      expect(QuestionPolicy::Scope.new(nil, Question.all).resolve).to match_array(questions)
    end
  end
end
