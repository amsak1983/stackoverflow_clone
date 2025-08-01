class Answer < ApplicationRecord
  # Associations
  belongs_to :question
  belongs_to :user
  has_many :links, dependent: :destroy, as: :linkable
  
  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true
  has_many_attached :files

  # Callbacks
  before_validation :sanitize_content

  # Validations
  validates :body, presence: true
  validate :no_dangerous_content
  validates_with FileAttachmentValidator

  # Scopes
  scope :newest_first, -> { order(created_at: :desc) }
  scope :best_first, -> { order(best: :desc, created_at: :desc) }

  # Returns a truncated version of the body for preview purposes
  def preview
    body.truncate(50) if body
  end

  def best?
    best == true
  end

  def make_best!
    question.answers.update_all(best: false)
    update!(best: true)
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
