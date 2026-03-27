class CreateStoreSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :store_subscriptions do |t|
      t.references :store, null: false, foreign_key: true
      t.references :subscription_plan, null: false, foreign_key: true
      t.string :stripe_subscription_id
      t.string :jazzcash_ref
      t.string :status
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
  end
end
