class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  belongs_to :product_variant, optional: true

  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_unit_price, on: :create

  def line_total
    unit_price * quantity
  end

  def variant_display
    product_variant&.display_name
  end

  private

  def set_unit_price
    self.unit_price ||= product.effective_price(product_variant)
    self.subtotal = unit_price * quantity
  end
end
