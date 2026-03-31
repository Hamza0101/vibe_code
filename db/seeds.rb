# ============================================================
# BazaarPK — Rich Seed Data
# Run: bin/rails db:seed
# ============================================================
puts "🌱 Seeding BazaarPK..."

# ── Helpers ─────────────────────────────────────────────────
def make_order(store:, user: nil, status:, items:, sale_channel: "online",
               pos_name: nil, pos_phone: nil, address: nil, created_offset: nil)
  order = store.orders.build(
    user:              user,
    address:           address,
    status:            status,
    sale_channel:      sale_channel,
    payment_method:    ["cash_on_delivery", "jazzcash", "easypaisa"].sample,
    delivery_fee:      sale_channel == "pos" ? 0 : [0, 50, 100, 150].sample,
    pos_customer_name: pos_name,
    pos_customer_phone: pos_phone,
    notes:             sale_channel == "pos" ? "POS walk-in sale" : ["Please ring doorbell", "Leave at gate", nil].sample
  )
  order.save!

  items.each do |product, qty|
    order.order_items.create!(
      product:    product,
      quantity:   qty,
      unit_price: product.price,
      subtotal:   product.price * qty
    )
  end

  order.calculate_totals!

  if created_offset
    order.update_columns(created_at: created_offset.ago, updated_at: created_offset.ago)
  end

  order
end

# ── Subscription Plans ───────────────────────────────────────
puts "\n📦 Subscription plans..."
plans_data = [
  { name: "Free",       price_pkr: 0,     product_limit: 20,  features: { "analytics"=>false,"featured"=>false,"sms"=>false,"bulk_import"=>false } },
  { name: "Starter",    price_pkr: 1500,  product_limit: 100, features: { "analytics"=>true, "featured"=>false,"sms"=>false,"bulk_import"=>false } },
  { name: "Pro",        price_pkr: 4000,  product_limit: nil, features: { "analytics"=>true, "featured"=>true, "sms"=>true, "bulk_import"=>false } },
  { name: "Enterprise", price_pkr: 15000, product_limit: nil, features: { "analytics"=>true, "featured"=>true, "sms"=>true, "bulk_import"=>true  } },
]
plans_data.each do |attrs|
  plan = SubscriptionPlan.find_or_initialize_by(name: attrs[:name])
  plan.update!(attrs)
end
free_plan       = SubscriptionPlan.find_by(name: "Free")
starter_plan    = SubscriptionPlan.find_by(name: "Starter")
pro_plan        = SubscriptionPlan.find_by(name: "Pro")
puts "  ✓ #{SubscriptionPlan.count} plans"

# ── Categories ───────────────────────────────────────────────
puts "\n🏷️  Categories..."
cats_data = {
  "grocery"  => ["Fresh Produce", "Dairy & Eggs", "Bakery & Bread", "Meat & Poultry",
                 "Beverages", "Snacks & Chips", "Pulses & Grains", "Frozen Foods",
                 "Condiments & Spices", "Household Essentials"],
  "pharmacy" => ["Medicines & Tablets", "Vitamins & Supplements", "Personal Care",
                 "Baby & Mother Care", "Medical Equipment", "Herbal & Ayurvedic",
                 "Skin Care", "Eye Care"],
  "clothing" => ["Men's Casual Wear", "Men's Formal Wear", "Women's Wear",
                 "Traditional & Ethnic", "Children's Clothing", "Footwear",
                 "Accessories & Bags", "Sportswear"],
}
cats_data.each do |store_type, names|
  names.each_with_index do |name, pos|
    Category.find_or_create_by!(name: name, store_type: store_type) { |c| c.position = pos }
  end
end
puts "  ✓ #{Category.count} categories"

# ── Admin ────────────────────────────────────────────────────
puts "\n👤 Admin..."
admin = User.find_or_initialize_by(email: "admin@bazaarpk.com")
admin.assign_attributes(name: "Admin", password: "admin123456",
                        password_confirmation: "admin123456", role: "admin")
admin.save!
puts "  ✓ admin@bazaarpk.com / admin123456"

# ── Customers ────────────────────────────────────────────────
puts "\n👥 Customers..."
customers_data = [
  { email: "customer@test.com",  name: "Sara Khan",     phone: "03001234567", city: "Lahore",    line1: "House 12, Street 5, Model Town" },
  { email: "hamza@test.com",     name: "Hamza Malik",   phone: "03111234567", city: "Karachi",   line1: "Flat 3B, Block 7, Gulshan-e-Iqbal" },
  { email: "ayesha@test.com",    name: "Ayesha Siddiqui", phone: "03211234567", city: "Islamabad", line1: "House 45, F-7/2, Islamabad" },
  { email: "usman@test.com",     name: "Usman Tariq",   phone: "03321234567", city: "Lahore",    line1: "Plot 8, DHA Phase 5" },
  { email: "fatima@test.com",    name: "Fatima Noor",   phone: "03451234567", city: "Faisalabad", line1: "Street 12, Peoples Colony" },
  { email: "bilal@test.com",     name: "Bilal Ahmed",   phone: "03001119999", city: "Multan",    line1: "House 77, Shah Rukn-e-Alam Colony" },
]
customers = customers_data.map do |cd|
  u = User.find_or_initialize_by(email: cd[:email])
  u.assign_attributes(name: cd[:name], phone: cd[:phone],
                      password: "password123", password_confirmation: "password123", role: "customer")
  u.save!
  u.addresses.find_or_create_by!(line1: cd[:line1]) do |a|
    a.city       = cd[:city]
    a.province   = ["Punjab","Sindh","KPK","Balochistan"].sample
    a.is_default = true
  end
  u
end
puts "  ✓ #{customers.count} customers"

# ── Vendors + Stores + Products ──────────────────────────────
puts "\n🏪 Vendors, stores & products..."

stores_blueprint = [
  # ── GROCERY ─────────────────────────────────────────────────
  {
    vendor: { email: "ahmed@test.com", name: "Ahmed Ali", phone: "03001234567" },
    store:  { name: "Ahmed Fresh Groceries", category: "grocery", city: "Lahore",
              address: "Model Town, Lahore", description: "Fresh fruits, vegetables, and daily essentials.", verified: true, featured: true, plan: pro_plan },
    products: [
      { name: "Tomatoes (1 kg)",      price: 80,   stock: 200, cat: "Fresh Produce",   desc: "Farm-fresh red tomatoes, hand-picked daily." },
      { name: "Potatoes (2 kg)",      price: 120,  stock: 150, cat: "Fresh Produce",   desc: "Premium quality potatoes from Punjab farms." },
      { name: "Onions (1 kg)",        price: 60,   stock: 180, cat: "Fresh Produce",   desc: "Red onions, perfect for cooking." },
      { name: "Fresh Milk (1 L)",     price: 180,  stock: 80,  cat: "Dairy & Eggs",    desc: "Pure farm fresh milk, collected twice daily." },
      { name: "Eggs (12 pcs)",        price: 280,  stock: 100, cat: "Dairy & Eggs",    desc: "Farm-fresh large white eggs." },
      { name: "Whole Wheat Bread",    price: 120,  stock: 60,  cat: "Bakery & Bread",  desc: "Freshly baked whole wheat bread, no preservatives." },
      { name: "Basmati Rice (5 kg)",  price: 1200, stock: 50,  cat: "Pulses & Grains", desc: "Aged sella basmati rice, extra long grain." },
      { name: "Red Lentils (1 kg)",   price: 240,  stock: 90,  cat: "Pulses & Grains", desc: "High protein masoor dal, cleaned and sorted." },
      { name: "Cooking Oil (5 L)",    price: 1850, stock: 40,  cat: "Household Essentials", desc: "Canola cooking oil, heart-healthy blend." },
      { name: "Mineral Water (6-pack)",price: 180, stock: 120, cat: "Beverages",       desc: "500ml bottles, pure natural mineral water." },
      { name: "Mango Juice (1 L)",    price: 150,  stock: 70,  cat: "Beverages",       desc: "100% natural mango pulp juice, no added sugar." },
      { name: "Lay's Classic Chips",  price: 80,   stock: 200, cat: "Snacks & Chips",  desc: "Crispy salted chips, family size pack." },
    ],
  },
  {
    vendor: { email: "karachi_grocery@test.com", name: "Rashid Hussain", phone: "03112345678" },
    store:  { name: "Karachi Daily Needs", category: "grocery", city: "Karachi",
              address: "Block 14, North Nazimabad", description: "Your one-stop daily grocery store in North Nazimabad.", verified: true, featured: false, plan: starter_plan },
    products: [
      { name: "Chicken Breast (1 kg)", price: 650,  stock: 40,  cat: "Meat & Poultry",  desc: "Halal boneless chicken breast, fresh cut." },
      { name: "Mutton (500 g)",        price: 900,  stock: 25,  cat: "Meat & Poultry",  desc: "Premium quality mutton from local farms." },
      { name: "Yogurt (500 g)",        price: 120,  stock: 60,  cat: "Dairy & Eggs",    desc: "Desi-style plain yogurt, creamy and thick." },
      { name: "Doodh Patti Tea",       price: 320,  stock: 80,  cat: "Beverages",       desc: "Premium Danedar tea leaves blend for kadak chai." },
      { name: "Frozen French Fries",   price: 350,  stock: 45,  cat: "Frozen Foods",    desc: "Crispy crinkle-cut fries, ready in 10 mins." },
      { name: "Garam Masala (100 g)",  price: 90,   stock: 100, cat: "Condiments & Spices", desc: "Aromatic whole spice mix, freshly ground." },
      { name: "Ketchup (800 g)",       price: 280,  stock: 70,  cat: "Condiments & Spices", desc: "Tomato ketchup, tangy and sweet." },
      { name: "Detergent Powder (1 kg)", price: 350, stock: 60, cat: "Household Essentials", desc: "Surf Excel whitening power, fresh fragrance." },
    ],
  },

  # ── PHARMACY ────────────────────────────────────────────────
  {
    vendor: { email: "dr_pharmacy@test.com", name: "Dr. Zara Qadir", phone: "03219876543" },
    store:  { name: "Zara Medical Store", category: "pharmacy", city: "Islamabad",
              address: "G-11 Markaz, Islamabad", description: "Trusted pharmacy with prescription & OTC medicines, vitamins, and medical equipment.", verified: true, featured: true, plan: pro_plan },
    products: [
      { name: "Panadol Extra (20 tabs)",   price: 180,  stock: 300, cat: "Medicines & Tablets", desc: "Fast relief for headaches and fever. Paracetamol 500mg." },
      { name: "Vitamin C 1000mg (60 tabs)",price: 750,  stock: 120, cat: "Vitamins & Supplements", desc: "Effervescent Vitamin C tablets, orange flavour." },
      { name: "Multivitamin Daily (30 caps)",price: 950, stock: 80, cat: "Vitamins & Supplements", desc: "Complete daily multivitamin for men and women." },
      { name: "Blood Pressure Monitor",    price: 3500, stock: 15,  cat: "Medical Equipment",    desc: "Digital automatic BP monitor with memory recall." },
      { name: "Face Wash (100 ml)",        price: 420,  stock: 90,  cat: "Skin Care",            desc: "Neutrogena oil-free acne face wash." },
      { name: "Sunscreen SPF50 (75 ml)",   price: 680,  stock: 55,  cat: "Skin Care",            desc: "Water-resistant SPF50 sunblock for daily use." },
      { name: "Diaper Pants M (36 pcs)",   price: 1400, stock: 40,  cat: "Baby & Mother Care",   desc: "Pampers Premium Care pull-up diapers, size M." },
      { name: "Baby Shampoo (200 ml)",     price: 380,  stock: 65,  cat: "Baby & Mother Care",   desc: "Johnson's No More Tears gentle baby shampoo." },
      { name: "Digital Thermometer",       price: 550,  stock: 50,  cat: "Medical Equipment",    desc: "Fast 10-second reading, fever alarm, memory." },
      { name: "Glucometer Kit",            price: 2200, stock: 20,  cat: "Medical Equipment",    desc: "OneTouch Select Plus blood glucose monitor." },
    ],
  },
  {
    vendor: { email: "lahore_pharma@test.com", name: "Imran Haider", phone: "03331234567" },
    store:  { name: "HealthPlus Pharmacy", category: "pharmacy", city: "Lahore",
              address: "DHA Phase 6, Main Boulevard", description: "24-hour pharmacy serving DHA and Cantt area.", verified: true, featured: false, plan: starter_plan },
    products: [
      { name: "Calcium + D3 (60 tabs)",   price: 480,  stock: 100, cat: "Vitamins & Supplements", desc: "Calcium 600mg with Vitamin D3 for bone health." },
      { name: "Fish Oil Omega-3 (60 caps)", price: 620, stock: 80,  cat: "Vitamins & Supplements", desc: "High-potency EPA/DHA omega-3 capsules." },
      { name: "Bandage Roll (5m)",         price: 120,  stock: 200, cat: "Medical Equipment",    desc: "Cotton elastic crepe bandage for sprains." },
      { name: "Hand Sanitizer (500 ml)",   price: 280,  stock: 150, cat: "Personal Care",        desc: "70% isopropyl alcohol-based hand sanitizer." },
      { name: "Neem Face Cream (50 g)",    price: 220,  stock: 110, cat: "Skin Care",            desc: "Himalaya Neem face cream for blemish-free skin." },
      { name: "Herbal Cough Syrup (100ml)",price: 320,  stock: 75,  cat: "Herbal & Ayurvedic",   desc: "Joshanda-based herbal cough & cold relief." },
    ],
  },

  # ── CLOTHING ────────────────────────────────────────────────
  {
    vendor: { email: "fashion@test.com", name: "Sana Javed", phone: "03451234567" },
    store:  { name: "Sana's Boutique", category: "clothing", city: "Lahore",
              address: "Liberty Market, Lahore", description: "Trendy women's and traditional Pakistani clothing.", verified: true, featured: true, plan: pro_plan },
    products: [
      { name: "Lawn Printed Kurti",      price: 1200, stock: 60,  cat: "Women's Wear",       desc: "3-piece printed lawn suit, summer collection.", variants: [["Size","S",0],["Size","M",0],["Size","L",100],["Size","XL",150]] },
      { name: "Silk Dupatta",            price: 850,  stock: 40,  cat: "Women's Wear",       desc: "Pure silk dupatta with embroidered border.", variants: [["Color","White",0],["Color","Pink",50],["Color","Cream",0]] },
      { name: "Bridal Lehenga",          price: 18500,stock: 5,   cat: "Traditional & Ethnic", desc: "Heavy embroidered bridal lehenga with dupatta." },
      { name: "Shalwar Kameez (Men's)",  price: 2200, stock: 35,  cat: "Men's Casual Wear",  desc: "Premium lawn 3-piece gents suit.", variants: [["Size","S",0],["Size","M",0],["Size","L",0],["Size","XL",100]] },
      { name: "Casual T-Shirt Men",      price: 650,  stock: 80,  cat: "Men's Casual Wear",  desc: "100% cotton round-neck tee, summer colors.", variants: [["Color","White",0],["Color","Navy",0],["Color","Black",0],["Color","Grey",0]] },
      { name: "Embroidered Kurta",       price: 1800, stock: 25,  cat: "Traditional & Ethnic", desc: "Hand-embroidered kurta for eid and weddings.", variants: [["Size","S",0],["Size","M",0],["Size","L",0]] },
      { name: "Ladies Khussa",           price: 1200, stock: 30,  cat: "Footwear",           desc: "Hand-stitched embroidered khussa, traditional design.", variants: [["Size","36",0],["Size","37",0],["Size","38",0],["Size","39",0]] },
      { name: "Kids Shalwar Suit",       price: 950,  stock: 50,  cat: "Children's Clothing", desc: "Comfortable cotton shalwar kameez for kids 5-10y.", variants: [["Age","5-6y",0],["Age","7-8y",0],["Age","9-10y",0]] },
      { name: "Handbag (Leather)",       price: 2800, stock: 20,  cat: "Accessories & Bags", desc: "Genuine leather tote bag, multiple compartments.", variants: [["Color","Brown",0],["Color","Black",0],["Color","Tan",200]] },
      { name: "Jogging Track Suit",      price: 1600, stock: 40,  cat: "Sportswear",         desc: "Polyester fleece tracksuit, warm and comfortable.", variants: [["Size","S",0],["Size","M",0],["Size","L",0],["Size","XL",150]] },
    ],
  },
  {
    vendor: { email: "mens_fashion@test.com", name: "Tariq Mehmood", phone: "03001239999" },
    store:  { name: "Tariq Men's Wear", category: "clothing", city: "Karachi",
              address: "Saddar, Karachi", description: "Affordable formal and casual menswear for every occasion.", verified: true, featured: false, plan: starter_plan },
    products: [
      { name: "Formal Dress Shirt",      price: 1400, stock: 55,  cat: "Men's Formal Wear",  desc: "Egyptian cotton formal shirt, slim fit.", variants: [["Size","S",0],["Size","M",0],["Size","L",0],["Size","XL",100]] },
      { name: "Chino Trousers",          price: 1800, stock: 40,  cat: "Men's Formal Wear",  desc: "Stretch chino pants, multiple colours.", variants: [["Color","Khaki",0],["Color","Navy",0],["Color","Charcoal",0]] },
      { name: "Leather Belt",            price: 750,  stock: 70,  cat: "Accessories & Bags", desc: "Genuine leather belt, silver buckle." },
      { name: "Sports Shoes",            price: 3200, stock: 30,  cat: "Footwear",           desc: "Lightweight mesh running shoes with cushioning.", variants: [["Size","40",0],["Size","41",0],["Size","42",0],["Size","43",0],["Size","44",150]] },
      { name: "Formal Shoes (Oxford)",   price: 4500, stock: 20,  cat: "Footwear",           desc: "Classic Oxford dress shoes, full-grain leather.", variants: [["Size","40",0],["Size","41",0],["Size","42",0],["Size","43",0]] },
      { name: "Polo Shirt",              price: 980,  stock: 65,  cat: "Men's Casual Wear",  desc: "Cotton pique polo shirt, breathable collar.", variants: [["Color","White",0],["Color","Navy",0],["Color","Green",0]] },
    ],
  },
]

created_vendors = []
created_stores  = []

stores_blueprint.each do |bp|
  # Vendor user
  v = User.find_or_initialize_by(email: bp[:vendor][:email])
  v.assign_attributes(
    name: bp[:vendor][:name], phone: bp[:vendor][:phone],
    password: "password123", password_confirmation: "password123", role: "vendor"
  )
  v.save!
  created_vendors << v

  # Store
  s = Store.find_or_initialize_by(user: v)
  s.assign_attributes(
    name:              bp[:store][:name],
    category:          bp[:store][:category],
    city:              bp[:store][:city],
    address:           bp[:store][:address],
    description:       bp[:store][:description],
    verified:          bp[:store][:verified],
    featured:          bp[:store].fetch(:featured, false),
    subscription_plan: bp[:store][:plan]
  )
  s.save!
  created_stores << s

  # Products
  bp[:products].each do |pd|
    category = Category.find_by(name: pd[:cat], store_type: bp[:store][:category])
    product  = s.products.find_or_initialize_by(name: pd[:name])
    product.assign_attributes(
      price:       pd[:price],
      stock:       pd[:stock],
      category:    category,
      description: pd[:desc],
      published:   true,
      featured:    [true, false, false].sample
    )
    product.save!

    # Variants
    if pd[:variants]
      pd[:variants].each do |v_name, v_value, v_mod|
        product.product_variants.find_or_create_by!(name: v_name, value: v_value) do |pv|
          pv.price_modifier = v_mod
          pv.stock          = (pd[:stock] / pd[:variants].size).ceil
        end
      end
    end
  end

  print "  ✓ #{s.name} (#{s.products.count} products)\n"
end

# ── Orders ───────────────────────────────────────────────────
puts "\n📦 Orders..."

all_statuses = %w[pending confirmed processing shipped delivered delivered delivered cancelled]

customers.each_with_index do |customer, ci|
  addr = customer.addresses.first

  # 4-6 online orders per customer, spread across multiple stores
  rand(4..6).times do |oi|
    store    = created_stores.sample
    products = store.products.published.to_a.sample(rand(1..3))
    next if products.empty?

    status  = all_statuses.sample
    offset  = rand(1..90).days + rand(0..23).hours

    items = products.map { |p| [p, rand(1..3)] }
    make_order(
      store:          store,
      user:           customer,
      status:         status,
      items:          items,
      address:        addr,
      created_offset: offset
    )
  end
end

# ── POS Orders ───────────────────────────────────────────────
pos_customers = [
  { name: "Khalid Bashir",  phone: "03001112233" },
  { name: "Nadia Iqbal",    phone: "03112223344" },
  { name: "Zubair Khan",    phone: "03213334455" },
  { name: "Samina Parveen", phone: "03334445566" },
  { name: "Faisal Raza",    phone: "03445556677" },
  { name: nil,              phone: nil           }, # anonymous walk-in
  { name: nil,              phone: nil           },
]

created_stores.each do |store|
  rand(5..10).times do
    pc       = pos_customers.sample
    products = store.products.published.to_a.sample(rand(1..4))
    next if products.empty?

    items  = products.map { |p| [p, rand(1..5)] }
    offset = rand(1..60).days + rand(0..23).hours

    make_order(
      store:          store,
      status:         "delivered",
      sale_channel:   "pos",
      items:          items,
      pos_name:       pc[:name],
      pos_phone:      pc[:phone],
      created_offset: offset
    )
  end
end

puts "  ✓ #{Order.count} total orders (#{Order.where(sale_channel: 'pos').count} POS, #{Order.where(sale_channel: 'online').count} online)"

# ── Reviews ──────────────────────────────────────────────────
puts "\n⭐ Reviews..."
review_bodies = [
  "Excellent quality! Exactly as described. Will order again.",
  "Very fresh produce. Delivery was quick and packaging was neat.",
  "Good product but slightly delayed delivery. Overall satisfied.",
  "Amazing quality for the price. Highly recommended!",
  "Product was okay, nothing special. Could be better.",
  "Top-notch quality! The seller was very responsive.",
  "Fresh and well-packed. Great experience overall.",
  "Average product. Packaging could be improved.",
  "Superb! This is my go-to store now. 5 stars!",
  "Decent quality. Delivery was on time.",
  "Love it! The quality exceeded my expectations.",
  "Good value for money. Will definitely reorder.",
  "Not what I expected but acceptable quality.",
  "Brilliant service and quality product. Recommended!",
  "Quick delivery, fresh stock. Happy customer!",
]

created_stores.each do |store|
  # 2-4 store reviews
  rand(2..4).times do
    reviewer = customers.sample
    next if store.reviews.exists?(user: reviewer)
    store.reviews.create!(
      user:     reviewer,
      rating:   rand(3..5),
      body:     review_bodies.sample,
      approved: true
    )
  end

  # 1-3 reviews per product
  store.products.published.each do |product|
    rand(1..3).times do
      reviewer = customers.sample
      next if product.reviews.exists?(user: reviewer)
      product.reviews.create!(
        user:     reviewer,
        rating:   rand(3..5),
        body:     review_bodies.sample,
        approved: [true, true, true, false].sample  # mostly approved
      )
    end
  end
end
puts "  ✓ #{Review.count} reviews"

# ── Summary ──────────────────────────────────────────────────
puts "\n✅ Done! Database seeded with:"
puts "   #{SubscriptionPlan.count} subscription plans"
puts "   #{Category.count} categories"
puts "   #{User.where(role: 'vendor').count} vendors"
puts "   #{Store.count} stores"
puts "   #{Product.count} products"
puts "   #{ProductVariant.count} product variants"
puts "   #{User.where(role: 'customer').count} customers"
puts "   #{Order.count} orders  (#{Order.where(sale_channel: 'pos').count} POS)"
puts "   #{Review.count} reviews"
puts ""
puts "🔑 Login credentials (all passwords: password123)"
puts "   Admin:     admin@bazaarpk.com  / admin123456"
puts "   Vendors:   ahmed@test.com, fashion@test.com, dr_pharmacy@test.com ..."
puts "   Customers: customer@test.com, hamza@test.com, ayesha@test.com ..."
puts "   Admin URL: http://localhost:3000/admin"
puts "   Vendor URL: http://localhost:3000/vendor"
