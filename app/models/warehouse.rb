class Warehouse < ApplicationRecord
    has_many :inventory_locations, dependent: :destroy
end
