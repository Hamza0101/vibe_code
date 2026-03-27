class Review < ApplicationRecord
  belongs_to :user
  belongs_to :reviewable, polymorphic: true

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :body, length: { minimum: 10, maximum: 1000 }, allow_blank: true
  validates :user_id, uniqueness: { scope: [:reviewable_type, :reviewable_id], message: "already reviewed this" }

  scope :approved, -> { where(approved: true) }
  scope :recent, -> { order(created_at: :desc) }

  def star_display
    "★" * rating + "☆" * (5 - rating)
  end
end
