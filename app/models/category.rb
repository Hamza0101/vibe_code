class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :parent, class_name: "Category", optional: true
  has_many :subcategories, class_name: "Category", foreign_key: :parent_id, dependent: :destroy
  has_many :products, dependent: :nullify

  enum store_type: { grocery: "grocery", pharmacy: "pharmacy", clothing: "clothing", all_types: "all" }

  validates :name, presence: true
  validates :store_type, presence: true

  scope :root, -> { where(parent_id: nil) }
  scope :for_type, ->(type) { where(store_type: [type, "all"]) }
  scope :ordered, -> { order(position: :asc, name: :asc) }
end
