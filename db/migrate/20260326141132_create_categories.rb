class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :slug
      t.string :store_type
      t.integer :position
      t.bigint :parent_id, null: true

      t.timestamps
    end
  end
end
