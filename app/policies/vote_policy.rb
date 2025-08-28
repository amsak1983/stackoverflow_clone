class VotePolicy < ApplicationPolicy
  def vote?
    user.present? && !user.author_of?(votable)
  end

  alias_method :up?, :vote?
  alias_method :down?, :vote?

  def destroy?
    user.present? && user.author_of?(record)
  end

  private

  def votable
    record.is_a?(Vote) ? record.votable : record
  end
end
