require 'rails_helper'
require_relative 'policy_spec_helper'

RSpec.describe AnswerPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:question_author) { create(:user) }
  let(:answer_author) { create(:user) }
  let(:question) { create(:question, user: question_author) }
  let(:answer) { create(:answer, question: question, user: answer_author) }

  it 'allows authenticated users to create answers' do
    expect(AnswerPolicy.new(user, Answer.new)).to permit_action(:create)
  end

  it 'denies guests from creating answers' do
    expect(AnswerPolicy.new(nil, Answer.new)).not_to permit_action(:create)
  end

  it 'allows answer authors to manage their answers' do
    expect(AnswerPolicy.new(answer_author, answer)).to permit_action(:update)
    expect(AnswerPolicy.new(answer_author, answer)).to permit_action(:destroy)
  end

  it 'allows question authors to set best answer' do
    expect(AnswerPolicy.new(question_author, answer)).to permit_action(:set_best)
  end

  it 'denies non-authors from managing answers' do
    expect(AnswerPolicy.new(user, answer)).not_to permit_action(:update)
    expect(AnswerPolicy.new(user, answer)).not_to permit_action(:destroy)
    expect(AnswerPolicy.new(user, answer)).not_to permit_action(:set_best)
    expect(AnswerPolicy.new(nil, answer)).not_to permit_action(:update)
  end

  describe "Scope" do
    let!(:answers) { create_list(:answer, 3) }

    it "returns all answers for any user" do
      expect(AnswerPolicy::Scope.new(user, Answer.all).resolve).to match_array(answers)
    end
  end
end
