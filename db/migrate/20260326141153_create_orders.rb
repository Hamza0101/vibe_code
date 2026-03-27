class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true
      t.references :address, null: true, foreign_key: true
      t.string :status
      t.decimal :subtotal
      t.decimal :delivery_fee
      t.decimal :total
      t.text :notes
      t.string :payment_method

      t.timestamps
    end
  end
end
