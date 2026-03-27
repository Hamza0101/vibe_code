class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def total
    cart_items.sum { |item| item.subtotal }
  end

  def item_count
    cart_items.sum(:quantity)
  end

  def empty?
    cart_items.none?
  end

  def add_item(product, variant = nil, quantity = 1)
    item = cart_items.find_or_create_by!(product: product, product_variant: variant)
    item.with_lock { item.increment!(:quantity, quantity) }
  end

  def remove_item(product, variant = nil)
    cart_items.where(product: product, product_variant: variant).destroy_all
  end

  def merge_with(other_cart)
    other_cart.cart_items.each do |item|
      add_item(item.product, item.product_variant, item.quantity)
    end
    other_cart.destroy
  end
end
