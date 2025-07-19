require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:questions).dependent(:destroy) }
    it { should have_many(:answers).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
  end
  
  describe '#author_of?' do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }
    let(:question) { create(:question, user: user) }
    
    it 'returns true if user is author of record' do
      expect(user).to be_author_of(question)
    end
    
    it 'returns false if user is not author of record' do
      expect(another_user).not_to be_author_of(question)
    end
  end
end
