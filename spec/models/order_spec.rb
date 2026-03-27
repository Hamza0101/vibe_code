require "rails_helper"

RSpec.describe Order, type: :model do
  describe "enums" do
    it "defaults to pending status" do
      order = build(:order)
      expect(order.pending?).to be true
    end

    it "defaults to cash_on_delivery payment method" do
      order = build(:order)
      expect(order.cash_on_delivery?).to be true
    end
  end

  describe "#can_cancel?" do
    it "allows cancellation when pending" do
      order = build(:order, status: "pending")
      expect(order.can_cancel?).to be true
    end

    it "allows cancellation when confirmed" do
      order = build(:order, status: "confirmed")
      expect(order.can_cancel?).to be true
    end

    it "does not allow cancellation when shipped" do
      order = build(:order, status: "shipped")
      expect(order.can_cancel?).to be false
    end

    it "does not allow cancellation when delivered" do
      order = build(:order, status: "delivered")
      expect(order.can_cancel?).to be false
    end
  end

  describe "#order_number" do
    it "returns formatted order number" do
      order = create(:order)
      expect(order.order_number).to match(/ORD-\d{6}/)
    end
  end
end
