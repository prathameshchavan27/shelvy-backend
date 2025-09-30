class Product < ApplicationRecord
  belongs_to :created_by_user, class_name: "User"

    validates :sku, presence: true, uniqueness: true
    validates :name, presence: true
    validates :price, numericality: { greater_than_or_equal_to: 0 }, unless: :is_bundle?
end
