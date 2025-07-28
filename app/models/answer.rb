class Answer < ApplicationRecord
  # Associations
  belongs_to :question
  belongs_to :user
  has_many_attached :files

  # Callbacks
  before_validation :sanitize_content

  # Validations
  validates :body, presence: true
  validate :no_dangerous_content
  validate :validate_file_type_and_size

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
  
  def validate_file_type_and_size
    return unless files.attached?
    
    files.each do |file|
      unless file.content_type.in?(%w[image/jpeg image/png image/gif application/pdf text/plain application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet])
        file.purge
        errors.add(:files, 'должны быть изображениями, PDF, текстом или офисными документами')
      end
      
      if file.blob.byte_size > 10.megabytes
        file.purge
        errors.add(:files, 'не должны превышать 10MB')
      end
    end
  end
end
