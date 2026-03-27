require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "requires email" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it "requires unique email" do
      create(:user, email: "test@test.com")
      user = build(:user, email: "test@test.com")
      expect(user).not_to be_valid
    end
  end

  describe "roles" do
    it "defaults to customer role" do
      user = build(:user)
      expect(user.customer?).to be true
    end

    it "can be a vendor" do
      user = build(:user, :vendor)
      expect(user.vendor?).to be true
    end

    it "can be an admin" do
      user = build(:user, :admin)
      expect(user.admin?).to be true
    end
  end

  describe "associations" do
    it "can have a store" do
      vendor = create(:user, :vendor)
      store = create(:store, user: vendor)
      expect(vendor.store).to eq store
    end

    it "can have many orders" do
      customer = create(:user, :customer)
      store = create(:store)
      create_list(:order, 3, user: customer, store: store)
      expect(customer.orders.count).to eq 3
    end
  end
end
