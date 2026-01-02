class InventorySummary < ApplicationRecord
  include Auditable

  belongs_to :product
  belongs_to :inventory_location
  belongs_to :inventory_status

  validates :product, :inventory_location, :inventory_status, presence: true
  validates :quantity_on_hand, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved_quantity, numericality: { greater_than_or_equal_to: 0 }
  validate :reserved_cannot_exceed_on_hand
  validate :check_location_constraints # Changed name to be more inclusive

  private

  def reserved_cannot_exceed_on_hand
    if reserved_quantity.present? && quantity_on_hand.present? && reserved_quantity > quantity_on_hand
      errors.add(:reserved_quantity, "cannot exceed quantity on hand")
    end
  end

  def check_location_constraints
    return unless inventory_location

    # Use .to_a to ensure we don't trigger multiple queries
    details = InventoryLocations::CurrentInventoryDetails.new(inventory_location.id).call.to_a

    # 1. Capacity Check
    if inventory_location.capacity.present?
      current_total = details.sum { |row| row["quantity_on_hand"].to_i }
      if (current_total + quantity_on_hand.to_i) > inventory_location.capacity
        errors.add(:base, "Exceeds inventory location capacity (#{inventory_location.capacity})")
      end
    end

    # 2. Unique Item Check
    if inventory_location.unique_item_limits.present?
      existing_skus = details.map { |row| row["sku"] }.uniq
      unless existing_skus.include?(product&.sku)
        if (existing_skus.count + 1) > inventory_location.unique_item_limits
          errors.add(:base, "Exceeds unique item limit (#{inventory_location.unique_item_limits})")
        end
      end
    end
  end
end
