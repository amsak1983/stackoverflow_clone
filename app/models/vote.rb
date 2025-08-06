# Vote model represents a user's vote on a votable resource (question or answer)
class Vote < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :votable, polymorphic: true

  # Validations
  validates :value, presence: true, inclusion: { in: [ -1, 1 ] }
  validates :user_id, uniqueness: { scope: [ :votable_id, :votable_type ] }

  # Scopes
  scope :upvotes, -> { where(value: 1) }
  scope :downvotes, -> { where(value: -1) }

  # Class methods

  # Get the count of upvotes for a votable resource
  # @param votable [ActiveRecord::Base] the votable resource
  # @return [Integer] the count of upvotes
  def self.upvotes_count(votable)
    where(votable: votable, value: 1).count
  end

  # Get the count of downvotes for a votable resource
  # @param votable [ActiveRecord::Base] the votable resource
  # @return [Integer] the count of downvotes
  def self.downvotes_count(votable)
    where(votable: votable, value: -1).count
  end
end
