class Api::V1::ProductsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_product, only: [ :show, :update ]

    def index
        authorize Product
        @products = Product.order(:id).includes(:components)

        render "api/v1/products/index", formats: :json, status: :ok
    end

    def show
        authorize Product
        render "api/v1/products/show", formats: :json, status: :ok
    end

    def create
        authorize Product
        service = ProductCreator.new(product_params, current_user, params)
        result = service.call
        render json: { product: result[:product] }, status: result[:status]
    end

    def update
        authorize Product
        if product_params.key?(:is_bundle)
            render json: { error: "Cannot change is_bundle attribute on update" }, status: :unprocessable_entity
            return
        end
        if @product.update(product_params)
            render json: { product: @product }, status: :ok
        else
            render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
    end

    private

    def product_params
        # Only permit fields directly on Product
        params.require(:product).permit(:name, :description, :price, :is_bundle)
    end


    def set_product
        @product = Product.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Product not found" }, status: :not_found
    end
end
