module InventoryLocations
    module Bundles
        class Bundler
            attr_reader :errors

            def initialize(params)
                @params = params
                @errors = []
            end

            def call
                ActiveRecord::Base.transaction do
                    validate_quantities!
                    process_components!
                    process_bundle_completion!
                end
            true
            rescue StandardError => e
                @errors << e.message
                false
            end

            private

            def validate_quantities!
             raise "Quantity to create must be greater than 0" if @params[:quantity_to_create].to_i <= 0
            end

            def process_components!
                @params[:components].each do |comp|
                    # Get the absolute latest record for this specific bin
                    latest = InventorySummary.where(
                    product_id: comp[:product_id],
                    inventory_location_id: comp[:inventory_location_id]
                    ).order(created_at: :desc).first

                    needed = comp[:quantity_per_bundle].to_i * @params[:quantity_to_create].to_i

                    if latest.nil? || latest.quantity_on_hand < needed
                        product_name = Product.find_by(id: comp[:product_id])&.name || "Unknown SKU"
                    raise "Insufficient stock for #{product_name} (Need #{needed}, have #{latest&.quantity_on_hand || 0})"
                    end

                    # IMMUTABLE STEP: Create new record for deduction
                    InventorySummary.create!(
                        product_id: comp[:product_id],
                        inventory_location_id: comp[:inventory_location_id],
                        inventory_status_id: latest.inventory_status_id,
                        quantity_on_hand: latest.quantity_on_hand - needed,
                        reserved_quantity: latest.reserved_quantity
                      # description: "Deduction for Bundle Creation: Product #{@params[:bundle_product_id]}"
                    )
                end
            end

            def process_bundle_completion!
                latest_bundle = InventorySummary.where(
                    product_id: @params[:bundle_product_id],
                    inventory_location_id: @params[:destination_location_id]
                ).order(created_at: :desc).first

                # IMMUTABLE STEP: Create new record for addition
                bundle = InventorySummary.create!(
                    product_id: @params[:bundle_product_id],
                    inventory_location_id: @params[:destination_location_id],
                    inventory_status_id: latest_bundle&.inventory_status_id || default_status_id,
                    quantity_on_hand: (latest_bundle&.quantity_on_hand || 0) + @params[:quantity_to_create].to_i,
                    reserved_quantity: latest_bundle&.reserved_quantity || 0
                )

                InventoryMovement.create!(
                    inventory_summary: InventorySummary.where(
                        product_id: @params[:bundle_product_id],
                        inventory_location_id: @params[:destination_location_id]
                    ).order(created_at: :desc).first,
                    transfer_from: nil,
                    transfer_to: InventoryLocation.find(@params[:destination_location_id]),
                    quantity_moved: @params[:quantity_to_create].to_i,
                    bundle: Product.find(@params[:bundle_product_id])
                )
            end

            def default_status_id
                InventoryStatus.find_by(name: "Sellable")&.id
            end
        end
    end
end
