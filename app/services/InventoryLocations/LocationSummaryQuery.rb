module InventoryLocations
  class LocationSummaryQuery
    attr_reader :warehouse_id

    def initialize(warehouse_id)
      @warehouse_id = warehouse_id
    end

    def call
      ActiveRecord::Base.connection.exec_query(
        ActiveRecord::Base.send(:sanitize_sql_array, [ sql, warehouse_id ])
      ).to_a
    end

    private

    def sql
      <<~SQL
        SELECT
          l.id,
          l.storage_id,
          l.capacity,
          COUNT(p.id) AS product_count,
          COALESCE(SUM(s.quantity_on_hand), 0) AS total_quantity
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
        GROUP BY l.id, l.storage_id, l.capacity
      SQL
    end
  end
end
