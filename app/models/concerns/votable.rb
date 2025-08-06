# Votable concern provides voting functionality for models
module Votable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable, dependent: :destroy
  end

  # Cast a vote for this resource by a user
  # @param user [User] the user casting the vote
  # @param value [Integer] the vote value (1 for upvote, -1 for downvote)
  # @return [Boolean] true if vote was successful, false otherwise
  def vote_by(user, value)
    return false if user.author_of?(self)

    vote = find_user_vote(user)

    if vote
      # Return false if trying to vote with the same value
      return false if vote.value == value
      # Update the vote if changing from upvote to downvote or vice versa
      vote.update(value: value)
    else
      # Create a new vote
      votes.create(user: user, value: value)
    end
  end

  # Cancel a user's vote for this resource
  # @param user [User] the user whose vote to cancel
  # @return [ActiveRecord::Relation] the result of the destroy operation
  def cancel_vote_by(user)
    votes.where(user: user).destroy_all
  end

  # Get the total rating (sum of all votes)
  # @return [Integer] the total rating
  def rating
    votes.sum(:value)
  end

  # Check if a user has voted on this resource
  # @param user [User] the user to check
  # @return [Boolean] true if the user has voted, false otherwise
  def voted_by?(user)
    votes.exists?(user: user)
  end

  # Get the value of a user's vote (1, -1 or nil)
  # @param user [User] the user whose vote to check
  # @return [Integer, nil] the vote value or nil if no vote
  def vote_value_by(user)
    vote = find_user_vote(user)
    vote&.value
  end

  private

  # Find a user's vote for this resource
  # @param user [User] the user whose vote to find
  # @return [Vote, nil] the vote or nil if not found
  def find_user_vote(user)
    votes.find_by(user: user)
  end
end
