class Admin::StoresController < Admin::BaseController
  before_action :set_store, only: %i[show edit update destroy verify toggle_featured]

  def index
    @q = Store.ransack(params[:q])
    @pagy, @stores = pagy(@q.result.includes(:user, :subscription_plan).order(created_at: :desc))
  end

  def show
  end

  def edit
  end

  def update
    if @store.update(store_params)
      redirect_to admin_store_path(@store), notice: "Store updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @store.destroy
    redirect_to admin_stores_path, notice: "Store deleted."
  end

  def verify
    @store.update(verified: !@store.verified)
    redirect_back fallback_location: admin_stores_path, notice: "Store verification status updated."
  end

  def toggle_featured
    @store.update(featured: !@store.featured)
    redirect_back fallback_location: admin_stores_path, notice: "Store featured status updated."
  end

  private

  def set_store
    @store = Store.friendly.find(params[:id])
  end

  def store_params
    params.require(:store).permit(:name, :description, :category, :city, :address, :phone, :verified, :featured, :subscription_plan_id)
  end
end
