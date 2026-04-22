class Api::V1::BundlesController < ApplicationController
  before_action :authenticate_user!

  def bundling_availability
    authorize :bundle, :bundling_availability?
    bundle = Product.find(params[:id])
    warehouse_id = params[:warehouse_id]

    # For each component, find the SINGLE best bin
    availability_report = bundle.components.map do |component|
        # Find the bin with the most stock for this SKU
        best_bin = InventorySummary.joins(:inventory_location)
                                    .where(product: component)
                                    .where(inventory_locations: { warehouse_id: warehouse_id })
                                    .order(quantity_on_hand: :desc)
                                    .first

        {
        component_id: component.id,
        sku: component.sku,
        name: component.name,
        best_location_id: best_bin&.inventory_location_id,
        bin_name: best_bin&.inventory_location&.storage_id || "N/A",
        available_in_bin: best_bin&.quantity_on_hand || 0
        }
    end

    # The limit is the smallest "available_in_bin" value among all components
    max_possible = availability_report.map { |c| c[:available_in_bin] }.min || 0

    render json: {
        bundle_id: bundle.id,
        max_bundlable_qty: max_possible,
        source_bins: availability_report
    }
  end

  def bundle_inventory
    authorize :bundle, :bundle_inventory?
    service = InventoryLocations::Bundles::Bundler.new(bundle_params)

    if service.call
        render json: {
        status: "success",
        message: "Bundling completed successfully."
        }, status: :ok
    else
        render json: {
        status: "error",
        errors: service.errors # This will now show "Insufficient stock for Individual Sock..."
        }, status: :unprocessable_entity
    end
  end

  private
  def bundle_params
    params.require(:bundle).permit(
        :bundle_product_id,
        :destination_location_id,
        :quantity_to_create,
        components: [ :inventory_location_id, :product_id, :quantity_per_bundle ]
    )
  end
end
