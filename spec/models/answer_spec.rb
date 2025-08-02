require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe 'associations' do
    it { should belong_to(:question) }
    it { should belong_to(:user) }
    it { should have_many(:links).dependent(:destroy) }
    it { should accept_nested_attributes_for(:links).allow_destroy(true) }
  end

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end

  describe 'scopes' do
    let!(:question) { create(:question) }
    let!(:old_answer) { create(:answer, question: question, created_at: 2.days.ago) }
    let!(:new_answer) { create(:answer, question: question, created_at: 1.day.ago) }
    let!(:best_answer) { create(:answer, question: question, best: true) }

    describe '.newest_first' do
      it 'returns answers in descending order by creation date' do
        regular_answers = question.answers.where(best: false)
        newest_ids = regular_answers.newest_first.pluck(:id)
        expect(newest_ids.first).to eq(new_answer.id)
        expect(newest_ids.last).to eq(old_answer.id)
      end
    end

    describe '.best_first' do
      it 'returns best answer first, then newest first' do
        expect(question.answers.best_first).to eq([ best_answer, new_answer, old_answer ])
      end
    end
  end

  describe '#make_best!' do
    let(:question) { create(:question) }
    let!(:answer1) { create(:answer, question: question, best: true) }
    let(:answer2) { create(:answer, question: question) }

    it 'sets the answer as best' do
      answer2.make_best!
      expect(answer2.reload.best).to be_truthy
    end

    it 'unsets previous best answer' do
      answer2.make_best!
      expect(answer1.reload.best).to be_falsey
    end
  end

  describe '#preview' do
    let(:question) { create(:question) }
    let(:answer) { create(:answer, question: question, body: 'A' * 80) }

    it 'returns truncated body' do
      expect(answer.preview.length).to eq(50)
      expect(answer.preview).to include('...')
    end
  end
end
