class LinkPolicy < ApplicationPolicy
  def destroy?
    user&.author_of?(record.linkable)
  end
end
