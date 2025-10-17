module Auditable
  extend ActiveSupport::Concern

  included do
    after_create  -> { log_audit("CREATE") }
    after_update  -> { log_audit("UPDATE") }
    after_destroy -> { log_audit("DELETE") }
  end

  private

  def log_audit(action)
    return unless Current.user.present?  # requires a thread-safe current user

    AuditLog.create!(
      user: Current.user,
      action_type: action,
      object_type: self.class.name,
      object_id: id,
      change_log: saved_changes
    )
  end
end
