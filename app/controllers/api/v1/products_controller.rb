class Api::V1::ProductsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_product, only: [ :show ]

    def index
        authorize Product
        @products = Product.all.includes(:components)

        render json: @products.map { |product|
            base = {
                id: product.id,
                sku: product.sku,
                name: product.name,
                price: product.price,
                is_bundle: product.is_bundle,
                inventory_location_id: product.inventory_location_id
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

    private
    def set_product
        @product = Product.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Product not found" }, status: :not_found
    end
end
