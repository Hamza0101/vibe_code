class StorePolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    user.present? && user.vendor?
  end

  def update?
    user.present? && (user.admin? || record.user == user)
  end

  def destroy?
    user.present? && user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.verified
      end
    end
  end
end
