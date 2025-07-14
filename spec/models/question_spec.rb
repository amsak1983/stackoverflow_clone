require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'associations' do
    it { should have_many(:answers).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
    it { should validate_length_of(:title).is_at_least(5) }
    it { should validate_length_of(:body).is_at_least(10) }
  end
  
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:question)).to be_valid
    end
  end
  
  describe 'instance methods' do
    let(:question) { create(:question) }
    
    it 'has correct attributes' do
      expect(question.title).to eq('How to implement authentication in Rails 8?')
      expect(question.body).to include('authentication in my Rails 8 application')
    end
  end
end
