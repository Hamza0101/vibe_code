class Vendor::PosController < Vendor::BaseController
  layout "pos"

  before_action :require_store!

  def show
    @categories = current_store.products.published
                               .joins(:category)
                               .distinct
                               .pluck("categories.name", "categories.id")
  end

  def search_products
    query = params[:q].to_s.strip
    category_id = params[:category_id]

    products = current_store.products.published.includes(:product_variants, image_attachment: :blob)

    if query.present?
      products = products.where("name ILIKE :q OR description ILIKE :q", q: "%#{query}%")
    end

    if category_id.present?
      products = products.where(category_id: category_id)
    end

    products = products.limit(40)

    render json: products.map { |p|
      {
        id: p.id,
        name: p.name,
        price: p.price.to_f,
        stock: p.stock,
        image_url: p.images.attached? ? url_for(p.images.first) : nil,
        variants: p.product_variants.map { |v|
          { id: v.id, name: v.name, value: v.value, price_modifier: v.price_modifier.to_f, stock: v.stock }
        }
      }
    }
  end

  def charge
    items_params = params.require(:items)
    customer_name = params[:customer_name].to_s.strip
    customer_phone = params[:customer_phone].to_s.strip
    payment_method = params[:payment_method] || "cash_on_delivery"

    ActiveRecord::Base.transaction do
      order = current_store.orders.build(
        sale_channel: :pos,
        status: :delivered,
        payment_method: payment_method,
        delivery_fee: 0,
        pos_customer_name: customer_name.presence,
        pos_customer_phone: customer_phone.presence,
        notes: "POS sale — walk-in customer"
      )
      order.save!

      items_params.each do |item|
        product = current_store.products.find(item[:product_id])
        variant = item[:variant_id].present? ? product.product_variants.find(item[:variant_id]) : nil
        unit_price = product.price + (variant&.price_modifier || 0)
        qty = item[:quantity].to_i.clamp(1, 999)

        order.order_items.create!(
          product: product,
          product_variant: variant,
          quantity: qty,
          unit_price: unit_price,
          subtotal: unit_price * qty
        )

        # Decrement stock if tracked
        if product.stock.present?
          product.decrement!(:stock, qty)
        end
        if variant&.stock.present?
          variant.decrement!(:stock, qty)
        end
      end

      order.calculate_totals!
      render json: { success: true, order_id: order.id, total: order.total.to_f }
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { success: false, error: "Product not found" }, status: :not_found
  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  def receipt
    @order = current_store.orders.find(params[:order_id])
    render layout: false
  end
end
