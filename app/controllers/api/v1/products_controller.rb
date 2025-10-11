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
        @product = Product.new(product_params)
        @product.created_by_user = current_user

        if @product.save
            render json: { product: @product }, status: :created
        else
            render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
    end

    private

    def product_params
        params.require(:product).permit(:name, :price)
    end

    def set_product
        @product = Product.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Product not found" }, status: :not_found
    end
end
