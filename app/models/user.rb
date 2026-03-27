class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { customer: "customer", vendor: "vendor", admin: "admin" }, _default: "customer"

  has_one :store, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_many :reviews, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_one :cart, dependent: :destroy

  validates :phone, format: { with: /\A(\+92|0)\d{10}\z/, message: "must be a valid Pakistani number" }, allow_blank: true

  def admin?
    role == "admin"
  end

  def vendor?
    role == "vendor"
  end

  def customer?
    role == "customer"
  end

  def full_name
    name.presence || email.split("@").first.humanize
  end
end
