module InventoryLocations
  module Bundles
    class Unbundler
        def initialize(params, user)
        # params: { product_id: 34, location_id: 1, quantity: 2 }
        @bundle = Product.find(params[:bundle_product_id])
        @location = InventoryLocation.find(params[:inventory_location_id])
        @quantity_to_unbundle = params[:quantity].to_i

        # We look for the bundle's current stock at this specific location
        @bundle_summary = InventorySummary.find_by(
            product: @bundle,
            inventory_location: @location
        )
        end

        def call
        return false unless @bundle_summary && @bundle_summary.quantity_on_hand >= @quantity_to_unbundle

        ActiveRecord::Base.transaction do
            # 1. Deduct the Bundles
            @bundle_summary.update!(
                quantity_on_hand: @bundle_summary.quantity_on_hand - @quantity_to_unbundle
            )

            # 2. Add the Components (Restoration)
            @bundle.components.each do |component|
                # Calculate total units to add (Qty * Case Pack)
                total_units = @quantity_to_unbundle * @bundle.case_pack_qty

                summary = InventorySummary.find_or_initialize_by(
                    product: component,
                    inventory_location: @location,
                    inventory_status: @bundle_summary.inventory_status # Keep same status (e.g., Available)
                )

                summary.quantity_on_hand = (summary.quantity_on_hand || 0) + total_units
                summary.reserved_quantity = (summary.reserved_quantity || 0)
                summary.save!

                # 3. Record Movement (Audit Log)
                InventoryMovement.create!(
                    inventory_summary: summary,
                    transfer_from: @location, # Source and destination are the same
                    transfer_to: @location,
                    quantity_moved: total_units,
                    bundle: @bundle # Useful for the history feature we discussed
                )
            end
        end
        Rails.logger.info("Successfully unbundled #{@quantity_to_unbundle} of #{@bundle.name} at #{@location.storage_id}")
        true
        rescue => e
        Rails.logger.error("Unbundle failed: #{e.message}")
        false
        end
    end
  end
end
