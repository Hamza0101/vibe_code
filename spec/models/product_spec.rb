require "rails_helper"

RSpec.describe Product, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      product = build(:product)
      expect(product).to be_valid
    end

    it "requires a name" do
      product = build(:product, name: nil)
      expect(product).not_to be_valid
    end

    it "requires a price greater than 0" do
      product = build(:product, price: 0)
      expect(product).not_to be_valid
    end

    it "requires non-negative stock" do
      product = build(:product, stock: -1)
      expect(product).not_to be_valid
    end
  end

  describe "scopes" do
    before do
      create(:product, published: true, stock: 10)
      create(:product, published: true, stock: 0)
      create(:product, :unpublished)
    end

    it "returns only published products" do
      expect(Product.published.count).to eq 2
    end

    it "returns only in-stock products" do
      expect(Product.in_stock.count).to eq 2
    end
  end

  describe "#in_stock?" do
    it "returns true when stock > 0" do
      product = build(:product, stock: 5)
      expect(product.in_stock?).to be true
    end

    it "returns false when stock is 0" do
      product = build(:product, stock: 0)
      expect(product.in_stock?).to be false
    end

    it "returns true when stock is nil (unlimited)" do
      product = build(:product, stock: nil)
      expect(product.in_stock?).to be true
    end
  end

  describe "#effective_price" do
    it "returns base price with no variant" do
      product = build(:product, price: 100)
      expect(product.effective_price).to eq 100
    end

    it "adds variant price modifier" do
      product = create(:product, price: 100)
      variant = create(:product_variant, product: product, price_modifier: 50)
      expect(product.effective_price(variant)).to eq 150
    end
  end
end
