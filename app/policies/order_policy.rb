class OrderPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && (user.admin? || record.user == user || record.store.user == user)
  end

  def create?
    user.present? && user.customer?
  end

  def update?
    user.present? && (user.admin? || record.store.user == user)
  end

  def cancel?
    show? && record.can_cancel?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.vendor? && user.store
        scope.where(store: user.store)
      else
        scope.where(user: user)
      end
    end
  end
end
