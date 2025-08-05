class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :created_rewards, class_name: 'Reward', dependent: :destroy
  has_many :received_rewards, class_name: 'Reward', foreign_key: 'recipient_id', dependent: :nullify

  def name
    email.split("@").first&.capitalize || "User"
  end

  def author_of?(record)
    record.user_id == id
  end
end
