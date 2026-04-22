class Api::V1::UnbundlesController < ApplicationController
  before_action :authenticate_user!

  def bundles
    authorize :bundle, :bundles?
    @products = Product.where(is_bundle: true).includes(:components).select(:id, :name, :sku, :case_pack_qty).order(:name)
    render json: { bundles: @products }, status: :ok
  end

  def unbundle_product
    authorize :bundle, :unbundle_product?
    if InventoryLocations::Bundles::Unbundler.new(unbundle_params, current_user).call
        render json: { message: "successfully unbundled" }, status: :ok
    else
        render json: { error: "Unbundling failed, Not enough inventory to unbundle" }, status: :unprocessable_entity
    end
  end

  private

  def unbundle_params
    params.require(:unbundle).permit(:bundle_product_id, :quantity, :inventory_location_id)
  end
end
