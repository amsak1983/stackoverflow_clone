class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user
  
  before_validation :sanitize_content
  
  validates :body, presence: true, length: { maximum: 1000 }
  validate :no_dangerous_content
  
  scope :newest_first, -> { order(created_at: :desc) }
  
  def preview
    body.truncate(100) if body
  end
  
  private
  
  def sanitize_content
    self.body = ActionController::Base.helpers.sanitize(body) if body.present?
  end
  
  def no_dangerous_content
    if body.present? && (body.include?("<script>") || body.include?("javascript:"))
      errors.add(:body, "contains potentially dangerous code")
    end
  end
end
