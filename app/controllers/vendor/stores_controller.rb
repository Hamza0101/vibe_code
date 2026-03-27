class Vendor::StoresController < Vendor::BaseController
  def show
    @store = current_store || Store.new
  end

  def edit
    @store = current_store || current_user.build_store
  end

  def update
    @store = current_store || current_user.build_store
    if @store.update(store_params)
      redirect_to vendor_store_path, notice: "Store updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def store_params
    params.require(:store).permit(:name, :description, :category, :city, :address, :phone, :logo, :banner)
  end
end
