class ProductPolicy < ApplicationPolicy
  def index?
    user.present? # any authenticated user can view products
  end

  def show?
    user.present?
  end

  def create?
    user.admin? || user.manager?
  end

  def update?
    user.admin? || user.manager?
  end

  def destroy?
    user.admin?
  end

  def lookup?
    user.present?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
