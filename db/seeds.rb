puts "Seeding database..."

# Subscription Plans
plans = [
  {
    name: "Free",
    price_pkr: 0,
    product_limit: 20,
    features: { "analytics" => false, "featured" => false, "sms" => false, "bulk_import" => false }
  },
  {
    name: "Starter",
    price_pkr: 1500,
    product_limit: 100,
    features: { "analytics" => true, "featured" => false, "sms" => false, "bulk_import" => false }
  },
  {
    name: "Pro",
    price_pkr: 4000,
    product_limit: nil,
    features: { "analytics" => true, "featured" => true, "sms" => true, "bulk_import" => false }
  },
  {
    name: "Enterprise",
    price_pkr: 15000,
    product_limit: nil,
    features: { "analytics" => true, "featured" => true, "sms" => true, "bulk_import" => true }
  }
]

plans.each do |plan_attrs|
  plan = SubscriptionPlan.find_or_initialize_by(name: plan_attrs[:name])
  plan.update!(plan_attrs)
  puts "  ✓ Plan: #{plan.name}"
end

# Admin user
admin = User.find_or_initialize_by(email: "admin@bazaarpk.com")
admin.name = "Admin"
admin.password = "admin123456"
admin.password_confirmation = "admin123456"
admin.role = "admin"
admin.save!
puts "  ✓ Admin: #{admin.email} (password: admin123456)"

# Categories
grocery_cats = ["Fresh Produce", "Dairy & Eggs", "Bakery", "Meat & Poultry", "Beverages", "Snacks"]
pharmacy_cats = ["Medicines", "Vitamins", "Personal Care", "Baby Care", "Medical Equipment"]
clothing_cats = ["Men's Wear", "Women's Wear", "Children's Wear", "Traditional Wear", "Accessories"]

[
  { cats: grocery_cats, type: "grocery" },
  { cats: pharmacy_cats, type: "pharmacy" },
  { cats: clothing_cats, type: "clothing" }
].each_with_index do |group, idx|
  group[:cats].each_with_index do |name, pos|
    Category.find_or_create_by!(name: name, store_type: group[:type]) do |c|
      c.position = pos
    end
  end
end
puts "  ✓ #{Category.count} categories created"

# Sample Vendor + Store
free_plan = SubscriptionPlan.find_by(slug: "free")

vendor = User.find_or_initialize_by(email: "vendor@test.com")
vendor.name = "Ahmed Ali"
vendor.password = "password123"
vendor.password_confirmation = "password123"
vendor.role = "vendor"
vendor.phone = "03001234567"
vendor.save!

store = Store.find_or_initialize_by(user: vendor)
store.name = "Ahmed Fresh Groceries"
store.category = "grocery"
store.city = "Lahore"
store.address = "Model Town, Lahore"
store.phone = "03001234567"
store.description = "Fresh fruits, vegetables, and daily essentials delivered to your door."
store.verified = true
store.subscription_plan = free_plan
store.save!

# Sample products
if store.products.count < 5
  ["Tomatoes (1kg)", "Potatoes (2kg)", "Onions (1kg)", "Milk (1L)", "Bread (loaf)"].each_with_index do |name, idx|
    cat = Category.find_by(store_type: "grocery")
    store.products.find_or_create_by!(name: name) do |p|
      p.price = (20 + idx * 15).to_d
      p.stock = 50
      p.category = cat
      p.published = true
      p.description = "Fresh and high quality #{name.downcase}"
    end
  end
end

puts "  ✓ Sample vendor: vendor@test.com (password: password123)"
puts "  ✓ Sample store: #{store.name}"

# Sample Customer
customer = User.find_or_initialize_by(email: "customer@test.com")
customer.name = "Sara Khan"
customer.password = "password123"
customer.password_confirmation = "password123"
customer.role = "customer"
customer.save!

customer.addresses.find_or_create_by!(line1: "House 12, Street 5") do |a|
  a.city = "Lahore"
  a.province = "Punjab"
  a.is_default = true
end

puts "  ✓ Sample customer: customer@test.com (password: password123)"
puts "\nDone! 🎉"
puts "\nLogin URLs:"
puts "  Admin:    http://localhost:3000/admin"
puts "  Vendor:   http://localhost:3000/vendor"
puts "  Customer: http://localhost:3000"
