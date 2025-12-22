class ProductCreator
    def initialize(params, user, extra_params)
        @params = params
        @user = user
        @extra_params = extra_params
    end

    def call
        @product = Product.new(@params)
        @product.created_by_user = @user

        # Save the product first so it has an ID
        unless @product.save
            return { errors: @product.errors.full_messages, status: :unprocessable_entity }
        end

        # Handle bundle-specific logic
        if ActiveModel::Type::Boolean.new.cast(@extra_params[:product][:is_bundle])
            @product.is_bundle = true

            # Add existing components if provided
            if @extra_params[:product][:component_ids].present?
            existing_components = Product.where(id: @extra_params[:product][:component_ids])
            @product.components << existing_components
            end

            # Create and add new components if provided
            if @extra_params[:product][:components].present?
                @extra_params[:product][:components].each do |comp_params|
                    new_component = Product.create!(
                    name: comp_params[:name],
                    price: comp_params[:price],
                    created_by_user: @user
                    )
                    @product.components << new_component
                end
            end

            # Ensure at least one component exists
            if @product.components.empty?
                return { error: "Bundle products must have at least one component.", status: :unprocessable_entity }
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

        { product: response_data, status: :created }
    end
end
