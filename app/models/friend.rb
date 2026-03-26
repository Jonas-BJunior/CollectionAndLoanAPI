class Friend < ApplicationRecord
  belongs_to :user

  has_many :loans, dependent: :restrict_with_error

  validates :name, presence: true
  validates :email, uniqueness: { scope: :user_id }, allow_blank: true
end
