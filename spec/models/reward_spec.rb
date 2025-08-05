require 'rails_helper'

RSpec.describe Reward, type: :model do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:recipient) { create(:user) }
  
  describe 'associations' do
    it { should belong_to(:question) }
    it { should belong_to(:user) }
    it { should belong_to(:recipient).class_name('User').optional }
  end
  
  describe 'validations' do
    subject { build(:reward, question: question, user: user) }
    
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }
    it { should validate_presence_of(:image) }
    
    describe 'image format validation' do
      it 'accepts valid image formats' do
        reward = build(:reward, question: question, user: user)
        reward.image.attach(
          io: StringIO.new('fake image data'),
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
        expect(reward).to be_valid
      end
      
      it 'rejects invalid file formats' do
        reward = build(:reward, question: question, user: user)
        reward.image.attach(
          io: StringIO.new('fake file data'),
          filename: 'test.txt',
          content_type: 'text/plain'
        )
        expect(reward).not_to be_valid
        expect(reward.errors[:image]).to include('must be a JPEG, PNG, GIF, or WebP image')
      end
    end
    
    describe 'dangerous content validation' do
      it 'accepts titles after sanitization removes script tags' do
        reward = build(:reward, title: 'Test <script>alert("xss")</script>', question: question, user: user)
        reward.image.attach(
          io: StringIO.new('fake image data'),
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
        expect(reward).to be_valid # After sanitization, script tags are removed
      end
      
      it 'rejects titles with javascript: protocol (not removed by sanitization)' do
        reward = build(:reward, title: 'javascript:alert("xss")', question: question, user: user)
        expect(reward).not_to be_valid
        expect(reward.errors[:title]).to include('contains potentially dangerous content')
      end
      
      it 'accepts safe titles' do
        reward = build(:reward, title: 'Safe reward title', question: question, user: user)
        reward.image.attach(
          io: StringIO.new('fake image data'),
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
        expect(reward).to be_valid
      end
    end
  end
  
  describe 'scopes' do
    let!(:awarded_reward) { create(:reward, question: question, user: user, recipient: recipient) }
    let!(:unawarded_reward) { create(:reward, question: create(:question, user: user), user: user) }
    
    describe '.awarded' do
      it 'returns only awarded rewards' do
        expect(Reward.awarded).to include(awarded_reward)
        expect(Reward.awarded).not_to include(unawarded_reward)
      end
    end
    
    describe '.unawarded' do
      it 'returns only unawarded rewards' do
        expect(Reward.unawarded).to include(unawarded_reward)
        expect(Reward.unawarded).not_to include(awarded_reward)
      end
    end
  end
  
  describe '#awarded?' do
    context 'when reward has a recipient' do
      let(:reward) { create(:reward, question: question, user: user, recipient: recipient) }
      
      it 'returns true' do
        expect(reward.awarded?).to be true
      end
    end
    
    context 'when reward has no recipient' do
      let(:reward) { create(:reward, question: question, user: user) }
      
      it 'returns false' do
        expect(reward.awarded?).to be false
      end
    end
  end
  
  describe '#award_to!' do
    let(:reward) { create(:reward, question: question, user: user) }
    
    it 'assigns the reward to the user' do
      expect { reward.award_to!(recipient) }.to change { reward.reload.recipient }.from(nil).to(recipient)
    end
    
    it 'marks the reward as awarded' do
      reward.award_to!(recipient)
      expect(reward.awarded?).to be true
    end
  end
  
  describe 'content sanitization' do
    it 'sanitizes title content on save' do
      reward = build(:reward, title: 'Title with <script>alert("test")</script> text', question: question, user: user)
      reward.image.attach(
        io: StringIO.new('fake image data'),
        filename: 'test.jpg',
        content_type: 'image/jpeg'
      )
      reward.save!
      expect(reward.reload.title).to eq('Title with alert("test") text')
    end
  end
end
