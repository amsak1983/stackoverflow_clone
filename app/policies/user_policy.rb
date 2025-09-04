class UserPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
