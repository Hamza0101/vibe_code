class CartsController < ApplicationController
  def show
    @cart = current_cart
    @cart_items = @cart.cart_items.includes(:product, :product_variant)
  end

  def add_item
    product = Product.published.find(params[:product_id])

    unless product.store.verified?
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: "This store is not available." }
        format.turbo_stream { render turbo_stream: turbo_stream.update("cart-flash", "<p class='text-red-600'>Store unavailable.</p>") }
      end
      return
    end

    unless product.in_stock?
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: "Product is out of stock." }
        format.turbo_stream { render turbo_stream: turbo_stream.update("cart-flash", "<p class='text-red-600'>Out of stock.</p>") }
      end
      return
    end

    variant = params[:product_variant_id].present? ? ProductVariant.find(params[:product_variant_id]) : nil
    quantity = (params[:quantity] || 1).to_i

    current_cart.add_item(product, variant, quantity)

    respond_to do |format|
      format.html { redirect_back fallback_location: cart_path, notice: "Item added to cart." }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("cart-count", current_cart.item_count.to_s),
          turbo_stream.update("cart-flash", "<p class='text-green-600 font-medium'>Added to cart!</p>")
        ]
      end
    end
  end

  def remove_item
    product = Product.find(params[:product_id])
    variant = params[:product_variant_id].present? ? ProductVariant.find(params[:product_variant_id]) : nil
    current_cart.remove_item(product, variant)
    redirect_to cart_path, notice: "Item removed."
  end

  def update_item
    item = current_cart.cart_items.find(params[:cart_item_id])
    qty = params[:quantity].to_i
    if qty <= 0
      item.destroy
    else
      item.update(quantity: qty)
    end
    redirect_to cart_path
  end
end
