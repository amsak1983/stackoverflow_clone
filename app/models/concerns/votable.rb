module Votable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable, dependent: :destroy
  end

  def vote_up(user)
    vote_by(user, 1)
  end

  def vote_down(user)
    vote_by(user, -1)
  end

  def vote_by(user, value)
    return false if user.author_of?(self)
    return false unless valid_vote_value?(value)

    vote = find_user_vote(user)

    if vote
      return false if vote.value == value
      vote.update(value: value)
    else
      votes.create(user: user, value: value)
    end
  end

  def cancel_vote_by(user)
    votes.where(user: user).destroy_all
  end

  def rating
    votes.sum(:value)
  end

  def voted_by?(user)
    votes.exists?(user: user)
  end

  def vote_value_by(user)
    vote = find_user_vote(user)
    vote&.value
  end

  private

  def find_user_vote(user)
    votes.find_by(user: user)
  end

  def valid_vote_value?(value)
    [ -1, 1 ].include?(value)
  end
end
