class CreateSubscriptionPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :subscription_plans do |t|
      t.string :name
      t.string :slug
      t.integer :price_pkr
      t.integer :product_limit
      t.jsonb :features

      t.timestamps
    end
  end
end
