class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :votable, polymorphic: true

  validates :value, presence: true, inclusion: { in: [ -1, 1 ] }
  validates :user_id, uniqueness: { scope: [ :votable_id, :votable_type ] }

  scope :upvotes, -> { where(value: 1) }
  scope :downvotes, -> { where(value: -1) }

  def self.upvotes_count(votable)
    where(votable: votable, value: 1).count
  end

  def self.downvotes_count(votable)
    where(votable: votable, value: -1).count
  end
end
