class Reward < ApplicationRecord
  # Associations
  belongs_to :question
  belongs_to :user # Creator of the reward
  belongs_to :recipient, class_name: 'User', optional: true # User who received the reward
  
  # File attachment for reward image
  has_one_attached :image
  
  # Callbacks
  before_validation :sanitize_content
  
  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :image, presence: true
  validate :no_dangerous_content
  validate :image_format_and_size
  
  # Scopes
  scope :awarded, -> { where.not(recipient: nil) }
  scope :unawarded, -> { where(recipient: nil) }
  
  # Instance methods
  def awarded?
    recipient.present?
  end
  
  def award_to!(user)
    update!(recipient: user)
  end
  
  private
  
  def sanitize_content
    self.title = ActionController::Base.helpers.sanitize(title) if title.present?
  end
  
  def no_dangerous_content
    return unless title.present?
    
    dangerous_patterns = [
      /<script/i,
      /javascript:/i,
      /on\w+\s*=/i,
      /<iframe/i
    ]
    
    if dangerous_patterns.any? { |pattern| title.match?(pattern) }
      errors.add(:title, 'contains potentially dangerous content')
    end
  end
  
  def image_format_and_size
    return unless image.attached?
    
    # Check file size (max 5MB)
    if image.blob.byte_size > 5.megabytes
      errors.add(:image, 'must be less than 5MB')
    end
    
    # Check file type
    allowed_types = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
    unless allowed_types.include?(image.blob.content_type)
      errors.add(:image, 'must be a JPEG, PNG, GIF, or WebP image')
    end
  end
end
