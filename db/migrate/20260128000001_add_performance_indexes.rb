class AddPerformanceIndexes < ActiveRecord::Migration[7.2]
  def change
    # Composite index for common inventory lookups (product + location + status)
    add_index :inventory_summaries,
              [:product_id, :inventory_location_id, :inventory_status_id],
              name: "idx_inventory_summaries_product_location_status"

    # Index for warehouse + storage lookups on locations
    add_index :inventory_locations,
              [:warehouse_id, :storage_id],
              name: "idx_inventory_locations_warehouse_storage"

    # Indexes for audit log queries
    add_index :audit_logs,
              [:object_type, :object_id],
              name: "idx_audit_logs_object"

    add_index :audit_logs, :created_at

    # Index for inventory movements by transfer locations
    add_index :inventory_movements, :transfer_from_id
    add_index :inventory_movements, :transfer_to_id

    # Index for inventory summaries ordered by created_at (for latest record queries)
    add_index :inventory_summaries, :created_at
  end
end
