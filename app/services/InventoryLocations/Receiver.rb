module InventoryLocations
  class Receiver
    attr_reader :errors

    def initialize(params)
      @product_id = params[:product_id]
      @location_id = params[:location_id]
      @quantity = params[:quantity].to_i
      @errors = []
    end

    def call
      validate_params!
      return false if @errors.any?

      ActiveRecord::Base.transaction do
        summary = create_inventory_summary
        create_inventory_movement(summary)
        summary
      end
    rescue ActiveRecord::RecordInvalid => e
      @errors << e.record.errors.full_messages.to_sentence
      false
    rescue StandardError => e
      Rails.logger.error("Receiving failed: #{e.message}")
      @errors << "An unexpected error occurred"
      false
    end

    private

    def validate_params!
      @errors << "Product is required" if @product_id.blank?
      @errors << "Location is required" if @location_id.blank?
      @errors << "Quantity must be greater than 0" if @quantity <= 0
    end

    def create_inventory_summary
      existing = latest_inventory_summary

      InventorySummary.create!(
        product_id: @product_id,
        inventory_location_id: @location_id,
        inventory_status: sellable_status,
        quantity_on_hand: (existing&.quantity_on_hand || 0) + @quantity,
        reserved_quantity: existing&.reserved_quantity || 0
      )
    end

    def latest_inventory_summary
      InventorySummary
        .where(product_id: @product_id, inventory_location_id: @location_id, inventory_status: sellable_status)
        .order(created_at: :desc)
        .first
    end

    def create_inventory_movement(summary)
      InventoryMovement.create!(
        inventory_summary: summary,
        transfer_from: nil,
        transfer_to: location,
        quantity_moved: @quantity,
        description: "Inbound Received"
      )
    end

    def sellable_status
      @sellable_status ||= InventoryStatus.find_by!(name: "Sellable")
    end

    def location
      @location ||= InventoryLocation.find(@location_id)
    end
  end
end
