class Order < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :store
  belongs_to :address, optional: true
  has_many :order_items, dependent: :destroy

  enum status: {
    pending: "pending",
    confirmed: "confirmed",
    processing: "processing",
    shipped: "shipped",
    delivered: "delivered",
    cancelled: "cancelled"
  }, _default: "pending"

  enum sale_channel: {
    online: "online",
    pos: "pos"
  }, _default: "online"

  enum payment_method: {
    cash_on_delivery: "cash_on_delivery",
    jazzcash: "jazzcash",
    easypaisa: "easypaisa",
    bank_transfer: "bank_transfer"
  }, _default: "cash_on_delivery"

  validates :status, presence: true
  validates :total, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_vendor, ->(store) { where(store: store) }

  before_create :generate_order_number

  def calculate_totals!
    self.subtotal = order_items.sum { |i| i.unit_price * i.quantity }
    self.delivery_fee ||= 0
    self.total = subtotal + delivery_fee
    save!
  end

  def can_cancel?
    pending? || confirmed?
  end

  def order_number
    "ORD-#{id.to_s.rjust(6, '0')}"
  end

  private

  def generate_order_number
    # order_number is derived from id after save; set a placeholder
    true
  end
end
