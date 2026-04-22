module InventoryLocations
  class Transferer
    def initialize(params)
      Rails.logger.info("Initializing Transferer with params: #{params.inspect}")
      @from_location = InventoryLocation.find(params["source_location_id"])
      @to_location = InventoryLocation.find(params["destination_location_id"])
      @payload = params["items"] # { inventory_summary_id: { quantity: x }, ... }
      @source_inventory = InventoryLocations::CurrentInventoryDetails.new(@from_location.id).call
      @destination_inventory = InventoryLocations::CurrentInventoryDetails.new(@to_location.id).call
    end

    def call
      ActiveRecord::Base.transaction do
        @payload.each do |inventory_summary_id, inner_hash|
            detail = @source_inventory.find { |d| d["inventory_summary_id"] == inventory_summary_id.to_i }
            detail2 = @destination_inventory.find { |d| d["inventory_summary_id"] == inventory_summary_id.to_i }
            next unless detail
            quantity_moved = [ inner_hash["quantity"].to_i, detail["quantity_on_hand"] ].min
            next if quantity_moved <= 0

            source = source_location_summary(detail, quantity_moved)
            Rails.logger.info("Source Summary created: #{source.inspect}")
            # Update destination location summary
            destination = destination_location_summary(detail2.present? ? detail2 : detail, quantity_moved, detail2.present? ? 1 : 0)
            Rails.logger.info("Destination Summary created: #{destination.inspect}")
            # Create inventory movement record
            InventoryMovement.create!(
              inventory_summary: source,
              transfer_from: @from_location,
              transfer_to: @to_location,
              quantity_moved: quantity_moved
            )
            InventoryMovement.create!(
              inventory_summary: destination,
              transfer_from: @from_location,
              transfer_to: @to_location,
              quantity_moved: quantity_moved
            )
            Rails.logger.info("Inventory Movement recorded: #{quantity_moved} units from #{@from_location.storage_id} to #{@to_location.storage_id}")
        end
      end
      true
    rescue => e
      Rails.logger.error("Transfer failed: #{e.message}")
      false
    end

    def source_location_summary(detail, quantity_moved)
        InventorySummary.create!(
          product: Product.find_by(sku: detail["sku"]),
          inventory_location: @from_location,
          inventory_status: InventoryStatus.find_by(name: detail["status"]),
          quantity_on_hand: detail["quantity_on_hand"] - quantity_moved,
          reserved_quantity: detail["reserved_quantity"],
        )
    end

    def destination_location_summary(detail, quantity_moved, check)
        validate_unique_item_limits if check==0
        InventorySummary.create!(
          product: Product.find_by(sku: detail["sku"]),
          inventory_location: @to_location,
          inventory_status: InventoryStatus.find_by(name: detail["status"]),
          quantity_on_hand: check==1 ? detail["quantity_on_hand"] + quantity_moved : quantity_moved,
          reserved_quantity: check==1 ? detail["reserved_quantity"] : 0,
        )
    end

    private
    def validate_unique_item_limits
      if @to_location.unique_item_limits == @destination_inventory.count
        raise "Cannot transfer to location #{@to_location.storage_id} as it has reached its unique item limit."
      end
    end
  end
end
