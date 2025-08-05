class CreateRewards < ActiveRecord::Migration[8.0]
  def change
    create_table :rewards do |t|
      t.string :title, null: false
      t.references :question, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true, comment: 'Creator of the reward'
      t.references :recipient, null: true, foreign_key: { to_table: :users }, comment: 'User who received the reward'

      t.timestamps
    end
    
    add_index :rewards, [:user_id, :question_id], unique: true
  end
end
