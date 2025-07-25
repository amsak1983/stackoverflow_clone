# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[8.0]
  def self.up
    # Check if indexes already exist before adding them
    unless index_exists?(:users, :email)
      add_index :users, :email, unique: true
    end

    unless index_exists?(:users, :reset_password_token)
      add_index :users, :reset_password_token, unique: true
    end
  end

  def self.down
    remove_index :users, :email if index_exists?(:users, :email)
    remove_index :users, :reset_password_token if index_exists?(:users, :reset_password_token)
  end
end
