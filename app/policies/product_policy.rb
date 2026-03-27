class ProductPolicy < ApplicationPolicy
  def show?
    record.published? || (user.present? && (user.admin? || record.store.user == user))
  end

  def create?
    user.present? && user.vendor? && record.store.user == user
  end

  def update?
    user.present? && (user.admin? || record.store.user == user)
  end

  def destroy?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user&.vendor? && user.store
        scope.where(store: user.store)
      else
        scope.published
      end
    end
  end
end
