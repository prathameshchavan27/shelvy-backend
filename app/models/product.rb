require "digest"
class Product < ApplicationRecord
  include Auditable
  before_validation :generate_sku, on: :create
  belongs_to :created_by_user, class_name: "User"

  validates :sku, presence: true, uniqueness: true
  validates :brand, presence: true
  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, unless: :is_bundle?

  has_many :bundled_products, foreign_key: :bundle_id, dependent: :destroy
  has_many :components, through: :bundled_products, source: :component

  has_many :inverse_bundled_products, class_name: "BundledProduct", foreign_key: :component_id, dependent: :destroy
  has_many :bundles, through: :inverse_bundled_products, source: :bundle
  has_many :inventory_summaries, dependent: :destroy
  has_many :inventory_locations, through: :inventory_summaries


  private

  def generate_sku
    return if sku.present?
    return if name.blank? || brand.blank?

    # 1. Standardize and clean the inputs
    clean_brand = brand.gsub(/[^A-Za-z0-9]/, "").upcase
    clean_name  = name.gsub(/[^A-Za-z0-9]/, "").upcase

    # 2. Build the 6-character prefix
    prefix_brand = clean_brand.ljust(3, "0").first(3)
    prefix_name  = clean_name.ljust(3, "0").first(3)
    base_prefix  = "#{prefix_brand}#{prefix_name}" # e.g., "YOGTEA"

    # 3. Create a deterministic 2-character suffix based on the full identity
    # We hash the combination of brand and name to get a unique "fingerprint"
    full_identity = "#{clean_brand}-#{clean_name}"
    hash_digest = Digest::SHA256.hexdigest(full_identity).upcase

    # Take 2 characters from the hash (e.g., the first two)
    deterministic_suffix = hash_digest.first(2)

    # 4. Combine to form the 8-character SKU
    generated_sku = "#{base_prefix}#{deterministic_suffix}"

    # Uniqueness Check (still good practice)
    if Product.exists?(sku: generated_sku)
      # If a collision happens (rare with hashes), we add the ID or a fallback
      # but for 8 chars, this is the most stable deterministic method.
      errors.add(:base, "Product with this name and brand already exists")
      throw(:abort)
    end
    self.sku = generated_sku
  end
end
