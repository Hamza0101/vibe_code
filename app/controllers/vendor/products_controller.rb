class Vendor::ProductsController < Vendor::BaseController
  before_action :require_store!
  before_action :set_product, only: %i[show edit update destroy]
  before_action :check_product_limit, only: %i[new create]

  def index
    @q = current_store.products.ransack(params[:q])
    @pagy, @products = pagy(@q.result.includes(:category).order(created_at: :desc))
  end

  def new
    @product = current_store.products.build
  end

  def create
    @product = current_store.products.build(product_params)
    if @product.save
      redirect_to vendor_products_path, notice: "Product created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to vendor_products_path, notice: "Product updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to vendor_products_path, notice: "Product deleted."
  end

  private

  def set_product
    @product = current_store.products.friendly.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :category_id, :published, :featured, images: [])
  end

  def check_product_limit
    if current_store.at_product_limit?
      redirect_to vendor_products_path,
                  alert: "You've reached your plan's product limit (#{current_store.product_limit}). Please upgrade your plan."
    end
  end
end
