class Api::V1::InventoryLocationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_inventory_location, only: [ :show, :history ]

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def inventory_locations_by_warehouse
    authorize InventoryLocation
    return if warehouse_id_missing?

    locations = InventoryLocations::LocationSummaryQuery.new(params[:warehouse_id]).call
    render json: { locations: locations }, status: :ok
  end

  def show
    authorize @location

    inventory_details = InventoryLocations::CurrentInventoryDetails.new(@location.id).call
    render json: { location: @location, inventory_details: inventory_details }, status: :ok
  end

  def history
    authorize @location
    products = Product.joins(:inventory_summaries).where(inventory_summaries: { inventory_location_id: @location.id }).distinct
    history = products.map do |product|
      summaries = InventorySummary.where(product: product, inventory_location: @location).order(id: :desc).limit(2)
      {
        name: product.name,
        sku: product.sku,
        history: summaries.map { |s|
          movement = InventoryMovement.where(inventory_summary: s, transfer_from: @location).order(id: :desc).first
          movement2 = InventoryMovement.where(inventory_summary: s, transfer_to: @location).order(id: :desc).first
          movement_info = if movement || movement2
            movement ||= movement2
            {
              quantity_moved: movement.quantity_moved,
              transfer_to: movement.transfer_to&.storage_id,
              transfer_from: movement.transfer_from&.storage_id,
              created_at: movement.created_at,
              bundle: movement.bundle ? { id: movement.bundle.id, name: movement.bundle.name } : nil,
              description: movement.description
            }
          end

          {
            quantity_on_hand: s.quantity_on_hand,
            reserved_quantity: s.reserved_quantity,
            status: s.inventory_status.name,
            created_at: s.created_at,
            movement: movement_info
          }
        },
        location: @location.storage_id
      }
    end
    render json: { history: history }, status: :ok
  end

  def available_capacity
    authorize InventoryLocation
    return if warehouse_id_missing?

    capacity = InventoryLocations::AvailableCapacity.new(params[:warehouse_id]).call
    render json: { capacity: capacity }, status: :ok
  end

  private

  def set_inventory_location
    @location = InventoryLocation.find(params[:id])
  end

  def warehouse_id_missing?
    return false if params[:warehouse_id].present?

    render json: { error: "warehouse_id parameter is required" }, status: :bad_request
    true
  end

  def render_not_found
    render json: { error: "Inventory Location not found" }, status: :not_found
  end
end
