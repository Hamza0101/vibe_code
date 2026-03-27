class SubscriptionPlan < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :stores, dependent: :nullify
  has_many :store_subscriptions, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :price_pkr, presence: true, numericality: { greater_than_or_equal_to: 0 }

  PLANS = %w[free starter pro enterprise].freeze

  scope :active, -> { where.not(slug: nil) }
  scope :by_price, -> { order(price_pkr: :asc) }

  def free?
    price_pkr.zero?
  end

  def unlimited_products?
    product_limit.nil?
  end

  def has_analytics?
    features&.dig("analytics").present?
  end

  def feature?(key)
    features&.dig(key.to_s) == true
  end
end
