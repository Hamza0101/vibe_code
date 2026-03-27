class Vendor::DashboardController < Vendor::BaseController
  before_action :require_store!

  def index
    @store = current_store
    @total_products = @store.products.count
    @pending_orders = @store.orders.pending.count
    @total_revenue = @store.total_revenue
    @recent_orders = @store.orders.recent.limit(5).includes(:user)
    @low_stock_products = @store.products.published.where("stock IS NOT NULL AND stock <= 5").limit(5)
    @revenue_this_month = @store.orders.delivered
                                 .where(created_at: Time.current.beginning_of_month..)
                                 .sum(:total)
    @plan = @store.active_plan
    @product_limit = @plan&.product_limit
  end
end
