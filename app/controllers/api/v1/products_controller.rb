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

        # Save the product first so it has an ID
        unless @product.save
            return render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end

        # Handle bundle-specific logic
        if ActiveModel::Type::Boolean.new.cast(params[:product][:is_bundle])
            @product.is_bundle = true

            # Add existing components if provided
            if params[:product][:component_ids].present?
            existing_components = Product.where(id: params[:product][:component_ids])
            @product.components << existing_components
            end

            # Create and add new components if provided
            if params[:product][:components].present?
                params[:product][:components].each do |comp_params|
                    new_component = Product.create!(
                    name: comp_params[:name],
                    price: comp_params[:price],
                    created_by_user: current_user
                    )
                    @product.components << new_component
                end
            end

            # Ensure at least one component exists
            if @product.components.empty?
            return render json: { error: "Bundle products must have at least one component." },
                            status: :unprocessable_entity
            end

            # Persist component associations
            @product.save!

        end
        response_data = {
            id: @product.id,
            name: @product.name,
            price: @product.price,
            is_bundle: @product.is_bundle
        }

        # Include components only if it's a bundle
        response_data[:components] = @product.components.as_json if @product.is_bundle?

        render json: { product: response_data }, status: :created
    end

    private

    def product_params
        # Only permit fields directly on Product
        params.require(:product).permit(:name, :price, :is_bundle)
    end


    def set_product
        @product = Product.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Product not found" }, status: :not_found
    end
end
