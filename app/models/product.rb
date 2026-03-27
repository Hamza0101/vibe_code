class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :store
  belongs_to :category, optional: true
  has_many :product_variants, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :nullify
  has_many :reviews, as: :reviewable, dependent: :destroy
  has_many_attached :images

  validates :name, presence: true, length: { minimum: 2, maximum: 200 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :published, -> { where(published: true) }
  scope :featured, -> { where(featured: true) }
  scope :in_stock, -> { where("stock IS NULL OR stock > 0") }
  scope :search_by_name, ->(q) { where("LOWER(name) LIKE LOWER(?)", "%#{q}%") if q.present? }

  def in_stock?
    stock.nil? || stock > 0
  end

  def effective_price(variant = nil)
    return price if variant.nil?
    price + variant.price_modifier.to_d
  end

  def average_rating
    reviews.approved.average(:rating)&.round(1) || 0
  end

  def primary_image
    images.first
  end
end
