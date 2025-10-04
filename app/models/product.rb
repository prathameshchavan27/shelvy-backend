class Product < ApplicationRecord
  before_validation :generate_sku, on: :create
  belongs_to :created_by_user, class_name: "User"

  validates :sku, presence: true, uniqueness: true
  validate :respect_location_unique_item_limits
  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, unless: :is_bundle?

  has_many :bundled_products, foreign_key: :bundle_id, dependent: :destroy
  has_many :components, through: :bundled_products, source: :component

  has_many :inverse_bundled_products, class_name: "BundledProduct", foreign_key: :component_id, dependent: :destroy
  has_many :bundles, through: :inverse_bundled_products, source: :bundle
  belongs_to :inventory_location

  private

  def generate_sku
    return if sku.present?
    return if name.blank?

    letters = name.gsub(/[^A-Za-z]/, "").upcase.chars.sort
    last_letter = letters.pop || "X"
    prefix = letters.first(7).join.ljust(7, "0")
    base_sku = prefix + last_letter

    if Product.exists?(sku: base_sku)
      errors.add(:base, "Product with this name or SKU already exists")
      throw(:abort)  # <---- stops creation
    end

    self.sku = base_sku
  end

  def respect_location_unique_item_limits
    return if inventory_location.nil?
    return if inventory_location.unique_item_limits.nil?

    current_unique_count = inventory_location.products.distinct.count
    # If this is a new record, it hasn’t been counted yet → add 1
    current_unique_count += 1 if new_record?

    if current_unique_count > inventory_location.unique_item_limits
      errors.add(:inventory_location, "has reached its unique product limit of #{inventory_location.unique_item_limits}")
    end
  end
end
