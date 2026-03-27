class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :line1
      t.string :line2
      t.string :city
      t.string :province
      t.string :postal_code
      t.boolean :is_default

      t.timestamps
    end
  end
end
