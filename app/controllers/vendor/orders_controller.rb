class Vendor::OrdersController < Vendor::BaseController
  before_action :require_store!
  before_action :set_order, only: %i[show update]

  def index
    @q = current_store.orders.ransack(params[:q])
    @pagy, @orders = pagy(@q.result.recent.includes(:user, :order_items))
    @status_counts = current_store.orders.group(:status).count
  end

  def show
    @order_items = @order.order_items.includes(:product, :product_variant)
  end

  def update
    new_status = order_params[:status]
    unless valid_status_transition?(@order.status, new_status)
      redirect_to vendor_order_path(@order), alert: "Invalid status transition from #{@order.status} to #{new_status}."
      return
    end

    if @order.update(order_params)
      OrderNotificationJob.perform_later(@order.id, "status_changed") if @order.status_previously_changed?
      redirect_to vendor_order_path(@order), notice: "Order status updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  VALID_TRANSITIONS = {
    "pending"    => %w[confirmed cancelled],
    "confirmed"  => %w[processing cancelled],
    "processing" => %w[shipped],
    "shipped"    => %w[delivered],
    "delivered"  => [],
    "cancelled"  => []
  }.freeze

  def valid_status_transition?(from, to)
    return true if to.blank?
    allowed = VALID_TRANSITIONS[from.to_s]
    allowed.present? && allowed.include?(to.to_s)
  end

  def set_order
    @order = current_store.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:status)
  end
end
