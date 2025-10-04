class InventoryLocation < ApplicationRecord
  belongs_to :warehouse
  has_many :products, dependent: :nullify

  validates :storage_id, presence: true
  validates :unique_item_limits, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :capacity, numericality: { greater_than_or_equal_to: 100 }, allow_nil: true
  validate :respect_unique_item_limits

  private

  def respect_unique_item_limits
    return if unique_item_limits.nil?

    if products.distinct.count > unique_item_limits
      errors.add(:products, "exceeds the unique item limit of #{unique_item_limits}")
    end
  end
end
