class Question < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  has_many :answers, dependent: :destroy

  # Callbacks
  before_validation :sanitize_content

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: true
  validate :no_dangerous_content

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  # Returns a truncated version of the body for preview purposes
  def preview
    body.truncate(100) if body
  end

  private

  def sanitize_content
    self.title = ActionController::Base.helpers.sanitize(title) if title.present?
    self.body = ActionController::Base.helpers.sanitize(body) if body.present?
  end

  def no_dangerous_content
    if title.present? && (title.include?("<script>") || title.include?("javascript:"))
      errors.add(:title, "contains potentially dangerous code")
    end

    if body.present? && (body.include?("<script>") || body.include?("javascript:"))
      errors.add(:body, "contains potentially dangerous code")
    end
  end
end
