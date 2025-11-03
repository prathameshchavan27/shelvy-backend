class Api::V1::ProductsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_product, only: [ :show, :update ]

    def index
        authorize Product
        @products = Product.order(:id).includes(:components)

        render json: @products.map { |product|
            base = {
                id: product.id,
                sku: product.sku,
                name: product.name,
                description: product.description,
                price: product.price,
                is_bundle: product.is_bundle
            }
            if product.is_bundle?
                base[:components] = product.components.map do |component|
                {
                    id: component.id,
                    name: component.name,
                    price: component.price
                }
                end
            end
            base
        }
    end

    def show
        authorize Product
        render json: {
            id: @product.id,
            sku: @product.sku,
            name: @product.name,
            description: @product.description,
            price: @product.price
        }, status: :ok
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
