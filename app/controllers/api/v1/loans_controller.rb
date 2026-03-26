class Api::V1::LoansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_loan, only: [ :show, :update, :destroy, :return_item ]

  def index
    loans = current_user.loans.includes(:item, :friend)
    loans = loans.where(item_id: params[:item_id]) if params[:item_id].present?
    loans = loans.where(friend_id: params[:friend_id]) if params[:friend_id].present?
    loans = params[:active] == "true" ? loans.where(returned_at: nil) : loans

    render json: {
      data: loans.order(created_at: :desc).map { |loan| serialized_loan(loan) }
    }
  end

  def show
    render json: { data: serialized_loan(@loan) }
  end

  def create
    loan = current_user.loans.new(loan_params)

    if loan.save
      loan.item.update!(status: :lent)
      render json: { data: serialized_loan(loan) }, status: :created
    else
      render_unprocessable(loan.errors.full_messages)
    end
  end

  def update
    if @loan.returned_at.present?
      return render_unprocessable([ "Returned loans cannot be updated" ])
    end

    if @loan.update(loan_update_params)
      render json: { data: serialized_loan(@loan) }
    else
      render_unprocessable(@loan.errors.full_messages)
    end
  end

  def destroy
    if @loan.returned_at.nil?
      @loan.item.update!(status: :available)
    end

    @loan.destroy!
    head :no_content
  end

  def return_item
    if @loan.returned_at.present?
      return render_unprocessable([ "Loan is already returned" ])
    end

    @loan.update!(returned_at: Time.current)
    @loan.item.update!(status: :available)
    render json: { data: serialized_loan(@loan) }
  end

  private

  def set_loan
    @loan = current_user.loans.find(params[:id])
  end

  def loan_params
    params.require(:loan).permit(:item_id, :friend_id, :loan_date, :expected_return_date)
  end

  def loan_update_params
    params.require(:loan).permit(:expected_return_date)
  end

  def serialized_loan(loan)
    loan.as_json.merge(
      item: loan.item.slice(:id, :title, :status),
      friend: loan.friend.slice(:id, :name, :email)
    )
  end
end
