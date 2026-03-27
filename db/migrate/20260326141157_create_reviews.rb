class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reviewable, polymorphic: true, null: false
      t.integer :rating
      t.text :body
      t.boolean :approved

      t.timestamps
    end
  end
end
