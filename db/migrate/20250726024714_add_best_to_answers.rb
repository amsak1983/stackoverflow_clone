class AddBestToAnswers < ActiveRecord::Migration[8.0]
  def change
    add_column :answers, :best, :boolean, default: false
  end
end
