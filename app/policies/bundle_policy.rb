class BundlePolicy < ApplicationPolicy
  def bundling_availability?
    user.present?
  end

  def bundle_inventory?
    user.admin? || user.manager?
  end

  def bundles?
    user.present?
  end

  def unbundle_product?
    user.admin? || user.manager?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
