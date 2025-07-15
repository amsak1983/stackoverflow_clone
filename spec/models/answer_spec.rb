require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe 'associations' do
    it { should belong_to(:question) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:body) }
  end
  
  describe 'scopes' do
    describe '.newest_first' do
      let!(:question) { create(:question) }
      let!(:old_answer) { create(:answer, question: question, created_at: 2.days.ago) }
      let!(:new_answer) { create(:answer, question: question, created_at: 1.day.ago) }
      
      it 'returns answers in descending order by creation date' do
        expect(question.answers.newest_first).to eq([new_answer, old_answer])
      end
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
