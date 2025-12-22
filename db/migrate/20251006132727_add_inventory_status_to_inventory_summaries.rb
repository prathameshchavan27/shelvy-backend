class AddInventoryStatusToInventorySummaries < ActiveRecord::Migration[7.2]
  def change
    add_reference :inventory_summaries, :inventory_status, null: false, foreign_key: true
  end
end
