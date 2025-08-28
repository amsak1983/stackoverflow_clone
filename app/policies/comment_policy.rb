class CommentPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def destroy?
    user&.author_of?(record)
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
