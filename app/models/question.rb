class Question < ApplicationRecord
  include Votable

  # Associations
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_one :best_answer, -> { where(best: true) }, class_name: "Answer"
  has_many_attached :files
  has_many :links, as: :linkable, dependent: :destroy
  has_one :reward, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :reward, allow_destroy: true, reject_if: :all_blank

  # Callbacks
  before_validation :sanitize_content

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: true
  validate :no_dangerous_content
  validates_with FileAttachmentValidator

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  # Returns a truncated version of the body for preview purposes
  def preview
    body.truncate(150) if body
  end

  def has_best_answer?
    answers.where(best: true).exists?
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
