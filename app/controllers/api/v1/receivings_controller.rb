class Api::V1::ReceivingsController < ApplicationController
  before_action :authenticate_user!

  def receive_inventory
    authorize :inventory_summary, :receive_inventory?

    service = InventoryLocations::Receiver.new(receive_params)

    if service.call
      render json: { message: "Inventory received successfully" }, status: :ok
    else
      render json: { error: service.errors.join(", "), code: "RECEIVING_FAILED" }, status: :unprocessable_entity
    end
  end

  private

  def receive_params
    params.require(:receiving).permit(:product_id, :location_id, :quantity)
  end
end
