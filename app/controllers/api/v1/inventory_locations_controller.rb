class Api::V1::InventoryLocationsController < ApplicationController
    before_action :authenticate_user!

    def inventory_locations_by_warehouse
        authorize InventoryLocation
        warehouse_id = params[:warehouse_id]
        if warehouse_id.present?
            sql = <<-SQL
                SELECT#{' '}
                    l.id,#{' '}
                    l.storage_id,#{' '}
                    COUNT(p.id) AS product_count,#{' '}
                    SUM(s.quantity_on_hand) AS total_quantity
                FROM inventory_locations l
                LEFT JOIN inventory_summaries s ON l.id = s.inventory_location_id
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
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Warehouse not found" }, status: :not_found
    end

    def show
        @location = InventoryLocation.find(params[:id])
        sql = <<-SQL
            SELECT
                p.name,
                p.sku,
                s.quantity_on_hand,
                s.reserved_quantity,
                st.name AS status
            FROM inventory_summaries s
            JOIN products p ON s.product_id = p.id
            JOIN inventory_statuses st ON s.inventory_status_id = st.id
            WHERE s.inventory_location_id = ?
        SQL
        @inventory_details = ActiveRecord::Base.connection.exec_query(
            ActiveRecord::Base.send(:sanitize_sql_array, [ sql, @location.id ])
        )

        authorize @location
        render json: { location: @location, inventory_details: @inventory_details }, status: :ok
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Inventory Location not found" }, status: :not_found
    end
end
