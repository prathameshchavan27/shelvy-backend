module InventoryLocations
  class AvailableCapacity
    attr_reader :warehouse_id

    def initialize(warehouse_id)
      @warehouse_id = warehouse_id
    end

    def call
      InventoryLocations::LocationSummaryQuery.new(warehouse_id).call.map do |location|
        {
          id: location["id"],
          storage_id: location["storage_id"],
          available_capacity: location["capacity"] - location["total_quantity"]
        }
      end
    end
  end
end
