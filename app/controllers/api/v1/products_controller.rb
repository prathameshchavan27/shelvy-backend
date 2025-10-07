class Api::V1::ProductsController < ApplicationController
    before_action :authenticate_user!

    def index
        authorize Product
        @products = Product.all.includes(:components)

        render json: @products.map { |product|
            base = {
                id: product.id,
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
end
