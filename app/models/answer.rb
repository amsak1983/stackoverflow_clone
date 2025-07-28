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
    
    allowed_types = %w[
      image/jpeg image/png image/gif 
      application/pdf 
      text/plain 
      application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document 
      application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    ]
    max_size = 10.megabytes
    
    files.each do |file|
      validate_file_type(file, allowed_types)
      validate_file_size(file, max_size)
    end
  end
  
  def validate_file_type(file, allowed_types)
    return if file.content_type.in?(allowed_types)
    file.purge
    errors.add(:files, 'must be images, PDFs, text or office documents')
  end
  
  def validate_file_size(file, max_size)
    return if file.blob.byte_size <= max_size
    file.purge
    errors.add(:files, 'must not exceed 10MB')
  end
end
