require "rails_helper"

RSpec.describe Store, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      store = build(:store)
      expect(store).to be_valid
    end

    it "requires a name" do
      store = build(:store, name: nil)
      expect(store).not_to be_valid
    end

    it "requires a category" do
      store = build(:store, category: nil)
      expect(store).not_to be_valid
    end

    it "requires a city" do
      store = build(:store, city: nil)
      expect(store).not_to be_valid
    end

    it "enforces one store per vendor" do
      vendor = create(:user, :vendor)
      create(:store, user: vendor)
      duplicate = build(:store, user: vendor)
      expect(duplicate).not_to be_valid
    end
  end

  describe "enums" do
    it "has grocery category" do
      store = build(:store, category: "grocery")
      expect(store.grocery?).to be true
    end

    it "has pharmacy category" do
      store = build(:store, :pharmacy)
      expect(store.pharmacy?).to be true
    end

    it "has clothing category" do
      store = build(:store, :clothing)
      expect(store.clothing?).to be true
    end
  end

  describe "scopes" do
    before do
      create(:store, verified: true, featured: true)
      create(:store, verified: true, featured: false)
      create(:store, :unverified)
    end

    it "returns only verified stores" do
      expect(Store.verified.count).to eq 2
    end

    it "returns only featured stores" do
      expect(Store.featured.count).to eq 1
    end
  end

  describe "#at_product_limit?" do
    let(:plan) { create(:subscription_plan, :free, product_limit: 2) }
    let(:vendor) { create(:user, :vendor) }
    let(:store) { create(:store, user: vendor, subscription_plan: plan) }

    it "returns false when under limit" do
      create(:product, store: store)
      expect(store.at_product_limit?).to be false
    end

    it "returns true when at limit" do
      create_list(:product, 2, store: store)
      expect(store.at_product_limit?).to be true
    end

    it "never hits limit with nil product_limit (Pro/Enterprise)" do
      pro_plan = create(:subscription_plan, :pro)
      store.update(subscription_plan: pro_plan)
      create_list(:product, 200, store: store)
      expect(store.at_product_limit?).to be false
    end
  end
end
