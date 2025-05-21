class User < ApplicationRecord
  validates :username, presence: true, uniqueness: true
  has_many :messages
  has_many :room_users
  has_many :rooms, through: :room_users
end
