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
    if @order.update(order_params)
      OrderNotificationJob.perform_later(@order.id, "status_changed") if @order.status_previously_changed?
      redirect_to vendor_order_path(@order), notice: "Order status updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = current_store.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:status)
  end
end
