class AnswerPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def update?
    user&.author_of?(record)
  end

  def destroy?
    user&.author_of?(record)
  end

  def set_best?
    user&.author_of?(record.question)
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
