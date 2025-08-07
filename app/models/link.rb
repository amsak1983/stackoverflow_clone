class Link < ApplicationRecord
  belongs_to :linkable, polymorphic: true

  before_validation :sanitize_url

  validates :name, presence: true, length: { maximum: 255 }
  validates :url, presence: true, format: {
    with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
    message: "must be a valid HTTP or HTTPS URL"
  }

  def gist?
    url.match?(/gist\.github\.com/)
  end

  def gist_id
    url.match(/gist\.github\.com\/(?:\w+\/)?(\w+)/)&.captures&.first
  end

  private

  def sanitize_url
    self.url = ActionController::Base.helpers.sanitize(url) if url.present?
  end
end
