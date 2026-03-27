class HomeController < ApplicationController
  def index
    @featured_stores = Store.verified.featured.includes(:subscription_plan).limit(8)
    @categories = Category.root.ordered
    @recent_stores = Store.verified.order(created_at: :desc).limit(6)
    @search_query = params[:q]
    if @search_query.present?
      @search_stores = Store.verified.where("LOWER(name) LIKE LOWER(?) OR LOWER(city) LIKE LOWER(?)",
                                            "%#{@search_query}%", "%#{@search_query}%").limit(10)
      @search_products = Product.published.search_by_name(@search_query).limit(10).includes(:store)
    end
  end
end
