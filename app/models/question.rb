class Question < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  has_many :answers, dependent: :destroy

  # Validations
  validates :title, :body, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  # Returns a truncated version of the body for preview purposes
  def preview
    body.truncate(100) if body
  end
end
