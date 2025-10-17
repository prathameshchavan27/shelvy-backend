class CreateAuditLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :audit_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action_type
      t.string :object_type
      t.integer :object_id
      t.jsonb :change_log

      t.timestamps
    end
  end
end
