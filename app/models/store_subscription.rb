class StoreSubscription < ApplicationRecord
  belongs_to :store
  belongs_to :subscription_plan

  enum status: { pending: "pending", active: "active", cancelled: "cancelled", expired: "expired" }

  validates :status, presence: true
  validates :starts_at, presence: true

  scope :active, -> { where(status: "active").where("ends_at IS NULL OR ends_at > ?", Time.current) }

  def expired?
    ends_at.present? && ends_at < Time.current
  end

  def days_remaining
    return nil if ends_at.nil?
    (ends_at.to_date - Date.current).to_i
  end
end
