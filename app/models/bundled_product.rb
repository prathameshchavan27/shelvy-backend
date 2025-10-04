class BundledProduct < ApplicationRecord
  belongs_to :bundle, class_name: "Product"
  belongs_to :component, class_name: "Product"

  validates :quantity, numericality: { greater_than: 0 }
  validate :bundle_must_be_a_bundle
  validate :component_must_not_be_bundle
  validate :no_self_reference

  private

  def bundle_must_be_a_bundle
    errors.add(:bundle, "must be a bundle product") unless bundle&.is_bundle?
  end

  def component_must_not_be_bundle
    errors.add(:component, "cannot be a bundle") if component&.is_bundle?
  end

  def no_self_reference
    errors.add(:component, "cannot be the same as bundle") if bundle_id == component_id
  end
end
