class Warehouse < ApplicationRecord
    has_many :inventory_locations, dependent: :destroy

    validates :name, presence: true
    validates :address, presence: true
end
