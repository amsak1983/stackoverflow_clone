module ActiveStorage
  class AttachmentPolicy < ApplicationPolicy
    def destroy?
      user&.author_of?(record.record)
    end
  end
end
