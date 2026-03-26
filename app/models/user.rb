class User < ApplicationRecord
  has_secure_password

  has_many :friends, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :loans, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
