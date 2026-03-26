class Item < ApplicationRecord
  belongs_to :user

  has_many :loans, dependent: :restrict_with_error

  enum :category, { game: 0, book: 1, movie: 2, boardgame: 3, other: 4 }
  enum :status, { available: 0, lent: 1 }

  validates :title, presence: true
  validates :category, presence: true
  validates :status, presence: true
end
