class Answer < ApplicationRecord
  include Votable

  belongs_to :question
  belongs_to :user
  has_many_attached :files
  has_many :links, as: :linkable, dependent: :destroy

  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: :all_blank

  before_validation :sanitize_content

  validates :body, presence: true
  validate :no_dangerous_content
  validates_with FileAttachmentValidator

  scope :newest_first, -> { order(created_at: :desc) }
  scope :best_first, -> { order(best: :desc, created_at: :desc) }

  def preview
    body.truncate(50) if body
  end

  def best?
    best == true
  end

  def make_best!
    question.answers.update_all(best: false)
    update!(best: true)

    if question.reward.present? && !question.reward.awarded?
      question.reward.award_to!(user)
    end
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
