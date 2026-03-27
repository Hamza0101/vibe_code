class CreateStores < ActiveRecord::Migration[7.1]
  def change
    create_table :stores do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :slug
      t.text :description
      t.string :category
      t.string :city
      t.string :address
      t.string :phone
      t.boolean :verified
      t.boolean :featured
      t.references :subscription_plan, null: true, foreign_key: true

      t.timestamps
    end
  end
end
