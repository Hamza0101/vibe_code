class ProductsController < ApplicationController
  def show
    @product = Product.published.friendly.find(params[:id])
    @store = @product.store
    @variants = @product.product_variants.in_stock
    @reviews = @product.reviews.approved.recent.includes(:user)
    @related_products = @store.products.published.in_stock
                               .where.not(id: @product.id)
                               .includes(:store, :category)
                               .limit(4)
  end
end
