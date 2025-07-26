require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'associations' do
    it { should have_many(:answers).dependent(:destroy) }
    it { should belong_to(:user) }
    it { should have_one(:best_answer).class_name('Answer').conditions(best: true) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
  end

  describe 'scopes' do
    describe '.recent' do
      let!(:old_question) { create(:question, created_at: 2.days.ago) }
      let!(:new_question) { create(:question, created_at: 1.day.ago) }

      it 'returns questions in descending order by creation date' do
        expect(Question.recent).to eq([new_question, old_question])
      end
    end
  end

  describe '#best_answer' do
    let(:question) { create(:question) }
    let!(:answer1) { create(:answer, question: question) }
    let!(:best_answer) { create(:answer, question: question, best: true) }
    let!(:answer2) { create(:answer, question: question) }

    it 'returns the best answer' do
      expect(question.best_answer).to eq(best_answer)
    end
  end

  describe '#has_best_answer?' do
    let(:question) { create(:question) }
    let!(:answer) { create(:answer, question: question) }

    it 'returns false when no best answer' do
      expect(question.has_best_answer?).to be_falsey
    end

    it 'returns true when has best answer' do
      answer.update!(best: true)
      expect(question.has_best_answer?).to be_truthy
    end
  end

  describe '#preview' do
    let(:question) { create(:question, body: 'A' * 200) }

    it 'returns truncated body' do
      expect(question.preview.length).to eq(150)
      expect(question.preview).to include('...')
    end
  end
end
