class Answer < ApplicationRecord
  # Associations
  belongs_to :question
  
  # Validations
  validates :body, presence: true
  
  # Scopes
  scope :newest_first, -> { order(created_at: :desc) }
  
  # Returns a truncated version of the body for preview purposes
  def preview
    body.truncate(50) if body
  end
end
