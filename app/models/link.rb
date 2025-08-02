class Link < ApplicationRecord
  belongs_to :linkable, polymorphic: true

  validates :name, presence: true
  validates :url, presence: true
  validate :validate_url_format

  def gist?
    url.present? && url.match?(%r{^https://gist\.github\.com/})
  end

  def gist_id
    return nil unless gist?
    
    url.split('/').last
  end

  private

  def validate_url_format
    return if url.blank?
    return if url.start_with?('http://', 'https://')
    
    errors.add(:url, 'must be a valid URL starting with http:// or https://')
  end
end
