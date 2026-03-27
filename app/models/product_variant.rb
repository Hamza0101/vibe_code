class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :nullify

  validates :name, presence: true
  validates :value, presence: true
  validates :stock, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :price_modifier, numericality: true, allow_nil: true

  scope :in_stock, -> { where("stock IS NULL OR stock > 0") }

  def display_name
    "#{name}: #{value}"
  end

  def in_stock?
    stock.nil? || stock > 0
  end
end
