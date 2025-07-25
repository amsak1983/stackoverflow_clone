class Answer < ApplicationRecord
  # Associations
  belongs_to :question
  belongs_to :user

  # Validations
  validates :body, presence: true

  # Scopes
  scope :newest_first, -> { order(created_at: :desc) }
  scope :sorted_by_best, -> { order(best: :desc, created_at: :asc) }

  # Returns a truncated version of the body for preview purposes
  def preview
    body.truncate(50) if body
  end

  # Check if this answer is marked as best
  def best?
    best
  end
end
