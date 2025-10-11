class InventorySummary < ApplicationRecord
  belongs_to :product
  belongs_to :inventory_location
  belongs_to :inventory_status

  validates :product, presence: true
  validates :inventory_location, presence: true
  validates :quantity_on_hand, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved_quantity, numericality: { greater_than_or_equal_to: 0 }
  validate :reserved_cannot_exceed_on_hand
  validates :inventory_status, presence: true


  private
  def reserved_cannot_exceed_on_hand
    if reserved_quantity.present? && quantity_on_hand.present? && reserved_quantity > quantity_on_hand
      errors.add(:reserved_quantity, "cannot exceed quantity on hand")
    end
  end
end
