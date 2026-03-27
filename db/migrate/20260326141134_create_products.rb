class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.references :store, null: false, foreign_key: true
      t.references :category, null: true, foreign_key: true
      t.string :name
      t.string :slug
      t.text :description
      t.decimal :price
      t.integer :stock
      t.boolean :published
      t.boolean :featured

      t.timestamps
    end
  end
end
