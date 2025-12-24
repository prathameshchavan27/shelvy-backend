require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:user) { create(:user) }

  before { Current.user = user }
  after  { Current.user = nil }

  it "creates an audit log on create" do
    product = Product.create!(name: "Sprite", brand: 'Test', price: 10, created_by_user: user)

    log = AuditLog.last
    expect(log.action_type).to eq("CREATE")
    expect(log.object_type).to eq("Product")
    expect(log.object_id).to eq(product.id)
    expect(log.user).to eq(user)
  end

  it "creates an audit log on update" do
    product = create(:product, created_by_user: user)
    product.update!(price: 12)

    log = AuditLog.last
    expect(log.action_type).to eq("UPDATE")
    expect(log.change_log.keys).to include("price")
  end

  it "creates an audit log on destroy" do
    product = create(:product, created_by_user: user)
    product.destroy!

    log = AuditLog.last
    expect(log.action_type).to eq("DELETE")
    expect(log.object_id).to eq(product.id)
  end
end
