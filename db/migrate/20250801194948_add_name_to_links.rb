class AddNameToLinks < ActiveRecord::Migration[8.0]
  def change
    add_column :links, :name, :string
  end
end
