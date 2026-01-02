class Api::V1::ReceivingsController < ApplicationController
  before_action :authenticate_user!

  def receive_inventory
    ActiveRecord::Base.transaction do
        summary = InventorySummary.new(
            product_id: receive_params[:product_id],
            inventory_location_id: receive_params[:location_id],
            inventory_status_id: InventoryStatus.find_by(name: "Sellable").id,
            quantity_on_hand: receive_params[:quantity],
            reserved_quantity: 0
        )

        summary.save!

        InventoryMovement.create!(
            inventory_summary: summary,
            transfer_from: nil,
            transfer_to: InventoryLocation.find(receive_params[:location_id]),
            quantity_moved: receive_params[:quantity],
            description: "Inbound Received"
        )
        render json: { message: "Inventory received successfully" }, status: :ok
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
  rescue => e
    render json: { error: "An unexpected error occurred: #{e.message}" }, status: :unprocessable_entity
  end

  private
  def receive_params
    params.require(:receiving).permit(:product_id, :location_id, :quantity)
  end
end
