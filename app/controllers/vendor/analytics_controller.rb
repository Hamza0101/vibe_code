class Vendor::AnalyticsController < Vendor::BaseController
  before_action :require_store!

  def show
    store = current_store
    range_days = (params[:days] || 30).to_i.clamp(7, 365)
    start_date = range_days.days.ago.to_date

    # Daily revenue for chart (last N days)
    @daily_revenue = store.orders
                          .where(status: :delivered)
                          .where("DATE(created_at) >= ?", start_date)
                          .group("DATE(created_at)")
                          .sum(:total)

    # Fill missing days with 0
    @chart_labels = (start_date..Date.today).map(&:to_s)
    @chart_data   = @chart_labels.map { |d| @daily_revenue[d.to_date]&.to_f || 0.0 }

    # Summary stats
    @total_revenue   = store.orders.delivered.sum(:total)
    @orders_count    = store.orders.count
    @pending_orders  = store.orders.pending.count
    @avg_order_value = store.orders.delivered.any? ? (store.orders.delivered.sum(:total) / store.orders.delivered.count) : 0

    # Online vs POS split
    @online_count = store.orders.where(sale_channel: :online).count
    @pos_count    = store.orders.where(sale_channel: :pos).count

    # Top products
    @top_products = store.order_items
                         .joins(:product)
                         .group("products.id", "products.name")
                         .order("SUM(order_items.subtotal) DESC")
                         .limit(5)
                         .sum("order_items.subtotal")

    @range_days = range_days
  end
end
