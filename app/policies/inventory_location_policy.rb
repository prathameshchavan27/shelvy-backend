class InventoryLocationPolicy < ApplicationPolicy
  def inventory_locations_by_warehouse?
    user.present?
  end

  def show?
    user.present?
  end

  def history?
    user.present?
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end
end
