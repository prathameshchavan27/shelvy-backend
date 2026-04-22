class InventorySummaryPolicy < ApplicationPolicy
  def receive_inventory?
    user.present? # All authenticated users can receive inventory
  end

  def transfer_inventory?
    user.present? # All authenticated users can transfer inventory
  end

  def locations_to_transfer?
    user.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
