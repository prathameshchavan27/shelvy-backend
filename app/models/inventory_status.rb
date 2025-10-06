class InventoryStatus < ApplicationRecord
    has_many :inventory_summaries, dependent: :nullify

    validates :name, presence: true, uniqueness: true, inclusion: {
        in: %w[Sellable Unsellable Damaged],
        message: "%{value} is not a valid inventory status"
    }
end
