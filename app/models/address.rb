class Address < ApplicationRecord
  belongs_to :user
  has_many :orders, dependent: :nullify

  PROVINCES = %w[Punjab Sindh KPK Balochistan AJK GB Islamabad].freeze

  validates :line1, presence: true
  validates :city, presence: true
  validates :province, presence: true, inclusion: { in: PROVINCES }

  scope :default_first, -> { order(is_default: :desc) }

  before_save :ensure_single_default

  def full_address
    [line1, line2, city, province, postal_code].compact.reject(&:blank?).join(", ")
  end

  private

  def ensure_single_default
    return unless is_default && is_default_changed?
    user.addresses.where.not(id: id).update_all(is_default: false)
  end
end
