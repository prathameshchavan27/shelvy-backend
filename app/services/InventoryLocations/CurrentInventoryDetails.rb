module InventoryLocations
    class CurrentInventoryDetails
        attr_reader :location_id

        def initialize(location_id)
            @location_id = location_id
        end

        def call
            sql = <<-SQL
                SELECT
                    s.id AS inventory_summary_id,
                    p.name,
                    p.sku,
                    s.quantity_on_hand,
                    s.reserved_quantity,
                    st.name AS status
                FROM inventory_summaries s
                JOIN products p ON s.product_id = p.id
                JOIN inventory_statuses st ON s.inventory_status_id = st.id
                WHERE s.id IN (
                    SELECT MAX(id)
                    FROM inventory_summaries
                    WHERE inventory_location_id = ?
                    GROUP BY product_id
                )
            SQL

            # Execute the query and return the result
            ActiveRecord::Base.connection.exec_query(
                ActiveRecord::Base.send(:sanitize_sql_array, [ sql, location_id ])
            )
        end
    end
end
