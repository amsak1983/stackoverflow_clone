class CreateLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :links do |t|
      t.string :name, null: false, limit: 255
      t.text :url, null: false
      t.references :linkable, polymorphic: true, null: false, index: true

      t.timestamps
    end
  end
end
