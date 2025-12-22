class InventoryMovement < ApplicationRecord
  include Auditable
  belongs_to :inventory_summary
  belongs_to :transfer_from, class_name: "InventoryLocation", optional: true
  belongs_to :transfer_to, class_name: "InventoryLocation", optional: true
  belongs_to :bundle, class_name: "Product", optional: true

  validates :inventory_summary, presence: true
  validates :quantity_moved, numericality: { only_integer: true, greater_than: 0 }
  validate :at_least_one_location_present

  def at_least_one_location_present
    if transfer_from.nil? && transfer_to.nil?
      errors.add(:base, "Must have at least transfer_from or transfer_to")
    end
  end
end
