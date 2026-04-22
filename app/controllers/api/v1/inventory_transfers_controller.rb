class Api::V1::InventoryTransfersController < ApplicationController
    before_action :authenticate_user!

    def locations_to_transfer
        authorize :inventory_summary, :locations_to_transfer?
        @locations = InventoryLocation.where(warehouse_id: params[:warehouse_id]).select(:id, :storage_id)
        render json: { locations: @locations }, status: :ok
    end

    def transfer_inventory
        authorize :inventory_summary, :transfer_inventory?
        if InventoryLocations::Transferer.new(payload).call
            render json: { message: "Inventory transferred to #{payload[:destination_location_id]}" }, status: :ok
        else
            render json: { error: "Inventory transfer failed" }, status: :unprocessable_entity
        end
    end

    private
    def payload
        params.require(:transfer_params).permit(:source_location_id, :destination_location_id, items: {})
    end
end
