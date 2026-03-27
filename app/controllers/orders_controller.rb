class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: %i[show cancel]

  def index
    @pagy, @orders = pagy(current_user.orders.recent.includes(:store, :order_items))
  end

  def show
    @order_items = @order.order_items.includes(:product, :product_variant)
  end

  def new
    @cart = current_cart
    if @cart.empty?
      redirect_to cart_path, alert: "Your cart is empty."
      return
    end
    @addresses = current_user.addresses.default_first
    @order = Order.new
  end

  def create
    @cart = current_cart
    if @cart.empty?
      redirect_to cart_path, alert: "Your cart is empty."
      return
    end

    # Group cart items by store (currently single-store checkout)
    store_id = @cart.cart_items.first.product.store_id
    @store = Store.find(store_id)

    @order = Order.new(
      user: current_user,
      store: @store,
      address_id: params[:order][:address_id],
      payment_method: params[:order][:payment_method] || "cash_on_delivery",
      notes: params[:order][:notes],
      delivery_fee: 100, # Rs. 100 flat delivery fee
      status: "pending"
    )

    ActiveRecord::Base.transaction do
      @order.save!
      @cart.cart_items.each do |item|
        @order.order_items.create!(
          product: item.product,
          product_variant: item.product_variant,
          quantity: item.quantity,
          unit_price: item.unit_price,
          subtotal: item.subtotal
        )
      end
      @order.calculate_totals!
      @cart.cart_items.destroy_all
    end

    OrderNotificationJob.perform_later(@order.id, "new_order")
    redirect_to order_path(@order), notice: "Order placed successfully! Order ##{@order.order_number}"
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = "Could not place order: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  def cancel
    if @order.can_cancel?
      @order.update(status: "cancelled")
      redirect_to order_path(@order), notice: "Order cancelled."
    else
      redirect_to order_path(@order), alert: "This order cannot be cancelled."
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end
end
