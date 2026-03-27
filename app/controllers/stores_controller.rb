class StoresController < ApplicationController
  def index
    @q = Store.verified.ransack(params[:q])
    scope = @q.result.includes(:subscription_plan)
    scope = scope.by_category(params[:category]) if params[:category].present?
    scope = scope.in_city(params[:city]) if params[:city].present?
    scope = scope.featured.or(scope) if params[:featured] == "true"
    @pagy, @stores = pagy(scope.order(featured: :desc, created_at: :desc))
    @categories = Category.root.ordered
    @cities = Store.verified.distinct.pluck(:city).sort
  end

  def show
    @store = Store.verified.friendly.find(params[:id])
    @q = @store.products.published.ransack(params[:q])
    @pagy, @products = pagy(@q.result.includes(:category).in_stock.order(featured: :desc))
    @categories = @store.products.published.joins(:category).distinct.pluck("categories.name", "categories.slug")
    @reviews = @store.reviews.approved.recent.limit(5).includes(:user)
    @avg_rating = @store.average_rating
  end
end
