require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'associations' do
    it { should have_many(:answers).dependent(:destroy) }
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
  
  describe '#preview' do
    let(:question) { create(:question, body: 'A' * 150) }
    
    it 'returns truncated body' do
      expect(question.preview.length).to eq(100)
      expect(question.preview).to include('...')
    end
  end
end
