class Api::V1::WarehousesController < ApplicationController
    before_action :authenticate_user!

    def create
        @warehouse = Warehouse.new(warehouse_params)
        if @warehouse.save
            render json: { warehouse: @warehouse }, status: :created
        else
            render json: { errors: @warehouse.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def index
        @warehouses = Warehouse.all
        render json: { "warehouses": @warehouses }, status: :ok
    end

    def show
        @warehouse = Warehouse.find(params[:id])
        render json: { "warehouse": @warehouse }, status: :ok
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Warehouse not found" }, status: :not_found
    end

    private
    def warehouse_params
        params.require(:warehouse).permit(:name, :address)
    end
end
