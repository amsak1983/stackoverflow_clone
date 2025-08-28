class RewardPolicy < ApplicationPolicy
  def index?
    user.present?
  end
end
