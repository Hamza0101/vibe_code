class Vendor::ProductVariantsController < Vendor::BaseController
  before_action :set_product

  def create
    @variant = @product.product_variants.build(variant_params)
    if @variant.save
      redirect_to edit_vendor_product_path(@product), notice: "Variant added."
    else
      redirect_to edit_vendor_product_path(@product), alert: @variant.errors.full_messages.to_sentence
    end
  end

  def update
    @variant = @product.product_variants.find(params[:id])
    if @variant.update(variant_params)
      redirect_to edit_vendor_product_path(@product), notice: "Variant updated."
    else
      redirect_to edit_vendor_product_path(@product), alert: @variant.errors.full_messages.to_sentence
    end
  end

  def destroy
    @variant = @product.product_variants.find(params[:id])
    @variant.destroy
    redirect_to edit_vendor_product_path(@product), notice: "Variant removed."
  end

  private

  def set_product
    @product = current_store.products.friendly.find(params[:product_id])
  end

  def variant_params
    params.require(:product_variant).permit(:name, :value, :price_modifier, :stock)
  end
end
