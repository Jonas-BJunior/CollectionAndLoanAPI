class Loan < ApplicationRecord
  belongs_to :user
  belongs_to :item
  belongs_to :friend

  validates :loan_date, presence: true
  validate :expected_return_date_after_loan_date
  validate :item_and_friend_belong_to_same_user
  validate :single_active_loan_per_item, on: :create

  scope :active, -> { where(returned_at: nil) }

  private

  def expected_return_date_after_loan_date
    return if expected_return_date.blank? || loan_date.blank?
    return unless expected_return_date < loan_date

    errors.add(:expected_return_date, "must be on or after loan_date")
  end

  def item_and_friend_belong_to_same_user
    return if item.blank? || friend.blank? || user.blank?

    if item.user_id != user_id
      errors.add(:item, "must belong to authenticated user")
    end

    if friend.user_id != user_id
      errors.add(:friend, "must belong to authenticated user")
    end
  end

  def single_active_loan_per_item
    return if item_id.blank?
    return unless Loan.active.where(item_id: item_id).exists?

    errors.add(:item, "already has an active loan")
  end
end
