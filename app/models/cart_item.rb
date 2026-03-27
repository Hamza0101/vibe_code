class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  belongs_to :product_variant, optional: true

  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }

  def subtotal
    product.effective_price(product_variant) * quantity
  end

  def unit_price
    product.effective_price(product_variant)
  end
end
