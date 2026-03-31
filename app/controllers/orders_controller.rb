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

    store_ids = @cart.cart_items.joins(:product).distinct.pluck("products.store_id")
    if store_ids.size > 1
      redirect_to cart_path, alert: "Your cart has items from multiple stores. Please keep items from one store only."
      return
    end

    @store = Store.verified.find_by(id: store_ids.first)
    unless @store
      redirect_to cart_path, alert: "Store is no longer available."
      return
    end

    address = nil
    if params[:order][:address_id].present?
      address = current_user.addresses.find_by(id: params[:order][:address_id])
      unless address
        flash[:alert] = "Invalid address selected."
        @addresses = current_user.addresses.default_first
        @order = Order.new
        render :new, status: :unprocessable_entity
        return
      end
    end

    @order = Order.new(
      user: current_user,
      store: @store,
      address: address,
      payment_method: params[:order][:payment_method] || "cash_on_delivery",
      notes: params[:order][:notes],
      delivery_fee: 100,
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
    @addresses = current_user.addresses.default_first
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
