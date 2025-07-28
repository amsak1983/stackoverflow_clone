class Question < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_one :best_answer, -> { where(best: true) }, class_name: "Answer"
  has_many_attached :files

  # Callbacks
  before_validation :sanitize_content

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: true
  validate :no_dangerous_content
  validate :validate_file_type_and_size

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
