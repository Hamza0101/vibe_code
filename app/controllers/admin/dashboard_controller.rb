class Admin::DashboardController < Admin::BaseController
  def index
    @total_stores = Store.count
    @verified_stores = Store.verified.count
    @total_users = User.count
    @total_orders = Order.count
    @orders_today = Order.where(created_at: Date.current.beginning_of_day..).count
    @revenue_today = Order.where(created_at: Date.current.beginning_of_day..).delivered.sum(:total)
    @mrr = StoreSubscription.active.joins(:subscription_plan).sum("subscription_plans.price_pkr")
    @recent_stores = Store.order(created_at: :desc).limit(5).includes(:user)
    @recent_orders = Order.recent.limit(5).includes(:user, :store)
  end
end
