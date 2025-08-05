require 'rails_helper'

RSpec.describe Link, type: :model do
  describe 'associations' do
    it { should belong_to(:linkable) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
    it { should validate_presence_of(:url) }
    
    it 'validates URL format' do
      link = build(:link, url: 'invalid-url')
      expect(link).not_to be_valid
      expect(link.errors[:url]).to include('must be a valid HTTP or HTTPS URL')
    end

    it 'accepts valid HTTP URLs' do
      link = build(:link, url: 'http://example.com')
      expect(link).to be_valid
    end

    it 'accepts valid HTTPS URLs' do
      link = build(:link, url: 'https://example.com')
      expect(link).to be_valid
    end
  end

  describe '#gist?' do
    it 'returns true for gist URLs' do
      link = build(:link, url: 'https://gist.github.com/user/123abc')
      expect(link.gist?).to be true
    end

    it 'returns false for non-gist URLs' do
      link = build(:link, url: 'https://github.com/user/repo')
      expect(link.gist?).to be false
    end
  end

  describe '#gist_id' do
    it 'extracts gist ID from URL' do
      link = build(:link, url: 'https://gist.github.com/user/123abc')
      expect(link.gist_id).to eq('123abc')
    end

    it 'handles anonymous gist URLs' do
      link = build(:link, url: 'https://gist.github.com/123abc')
      expect(link.gist_id).to eq('123abc')
    end
  end
end
