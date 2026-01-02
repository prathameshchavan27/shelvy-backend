class Api::V1::InventoryLocationsController < ApplicationController
    before_action :authenticate_user!
    before_action :setInventoryLocation, only: [ :show, :history ]

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    def inventory_locations_by_warehouse
        authorize InventoryLocation
        warehouse_id = params[:warehouse_id]
        if warehouse_id.present?
            sql = <<-SQL
                SELECT
                    l.id,
                    l.storage_id,
                    COUNT(p.id) AS product_count,
                    SUM(s.quantity_on_hand) AS total_quantity
                FROM inventory_locations l
                LEFT JOIN (
                    SELECT *
                    FROM inventory_summaries
                    WHERE id IN (
                        SELECT MAX(id)
                        FROM inventory_summaries
                        GROUP BY product_id, inventory_location_id
                    )
                ) s ON l.id = s.inventory_location_id
                LEFT JOIN products p ON s.product_id = p.id
                WHERE l.warehouse_id = ?
                GROUP BY l.id, l.storage_id
            SQL
            @locations = ActiveRecord::Base.connection.exec_query(
                ActiveRecord::Base.send(:sanitize_sql_array, [ sql, warehouse_id ])
            )
            render json: { locations: @locations }, status: :ok
        else
            render json: { error: "warehouse_id parameter is required" }, status: :bad_request
        end
    end

    def show
        @location = InventoryLocation.find(params[:id])
        authorize InventoryLocation

        @inventory_details = InventoryLocations::CurrentInventoryDetails.new(@location.id).call
        render json: { location: @location, inventory_details: @inventory_details }, status: :ok
    end

    def history
        authorize InventoryLocation
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
                    else
                        nil
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
        sql = <<-SQL
            SELECT
                l.id,
                l.storage_id,
                COUNT(p.id) AS product_count,
                SUM(s.quantity_on_hand) AS total_quantity
            FROM inventory_locations l
            LEFT JOIN (
                SELECT *
                FROM inventory_summaries
                WHERE id IN (
                    SELECT MAX(id)
                    FROM inventory_summaries
                    GROUP BY product_id, inventory_location_id
                )
            ) s ON l.id = s.inventory_location_id
            LEFT JOIN products p ON s.product_id = p.id
            WHERE l.warehouse_id = ?
            GROUP BY l.id, l.storage_id
        SQL
        @locations = ActiveRecord::Base.connection.exec_query(
            ActiveRecord::Base.send(:sanitize_sql_array, [ sql, params[:warehouse_id] ])
        )
        capacity = @locations.map do |loc|
            location = InventoryLocation.find(loc["id"])
            {
                id: loc["id"],
                storage_id: loc["storage_id"],
                available_capacity: location.capacity - (loc["total_quantity"] || 0)
            }
        end
        render json: { capacity: capacity }, status: :ok
    end

    private
    def setInventoryLocation
        @location = InventoryLocation.find(params[:id])
    end

    def render_not_found
        render json: { error: "Inventory Location not found" }, status: :not_found
    end
end
