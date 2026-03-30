class AddPosFieldsToOrders < ActiveRecord::Migration[7.1]
  def change
    # Allow null user_id for walk-in POS sales
    change_column_null :orders, :user_id, true

    add_column :orders, :sale_channel, :string, default: "online", null: false
    add_column :orders, :pos_customer_name, :string
    add_column :orders, :pos_customer_phone, :string

    add_index :orders, :sale_channel
  end
end
