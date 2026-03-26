class Api::V1::ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:show, :update, :destroy]

  def index
    items = current_user.items
    items = items.where(category: params[:category]) if params[:category].present?
    items = items.where(status: params[:status]) if params[:status].present?
    render json: { data: items.order(created_at: :desc) }
  end

  def show
    render json: { data: @item }
  end

  def create
    item = current_user.items.new(item_params)
    item.status ||= :available

    if item.save
      render json: { data: item }, status: :created
    else
      render_unprocessable(item.errors.full_messages)
    end
  end

  def update
    if @item.update(item_params)
      render json: { data: @item }
    else
      render_unprocessable(@item.errors.full_messages)
    end
  end

  def destroy
    if @item.destroy
      head :no_content
    else
      render_unprocessable(@item.errors.full_messages)
    end
  end

  private

  def set_item
    @item = current_user.items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:title, :category, :platform, :notes, :cover_image_url, :status)
  end
end
