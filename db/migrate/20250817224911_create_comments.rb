class CreateComments < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:comments)
      create_table :comments do |t|
        t.text :body, null: false
        t.references :user, null: false, foreign_key: true
        t.references :commentable, polymorphic: true, null: false

        t.timestamps
      end

      add_index :comments, [:commentable_type, :commentable_id]
    end
  end
end
