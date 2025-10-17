class AuditLog < ApplicationRecord
  belongs_to :user
  validates :action_type, :object_type, :object_id, presence: true
end
