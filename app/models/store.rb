class Store < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :user
  belongs_to :subscription_plan, optional: true
  has_many :store_subscriptions, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_many :reviews, as: :reviewable, dependent: :destroy
  has_one_attached :logo
  has_one_attached :banner

  enum category: { grocery: "grocery", pharmacy: "pharmacy", clothing: "clothing" }

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :category, presence: true
  validates :city, presence: true
  validates :user_id, uniqueness: { message: "can only have one store" }

  scope :verified, -> { where(verified: true) }
  scope :featured, -> { where(featured: true) }
  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
  scope :in_city, ->(city) { where("LOWER(city) = LOWER(?)", city) if city.present? }
  scope :published, -> { verified }

  def active_plan
    active_sub = store_subscriptions.active.order(created_at: :desc).first
    active_sub&.subscription_plan || subscription_plan || SubscriptionPlan.find_by(slug: "free")
  end

  def product_limit
    active_plan&.product_limit
  end

  def at_product_limit?
    limit = product_limit
    return false if limit.nil?
    products.count >= limit
  end

  def average_rating
    reviews.approved.average(:rating)&.round(1) || 0
  end

  def total_revenue
    orders.delivered.sum(:total)
  end
end
