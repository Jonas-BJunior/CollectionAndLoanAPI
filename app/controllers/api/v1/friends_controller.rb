class Api::V1::FriendsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_friend, only: [:show, :update, :destroy]

  def index
    render json: { data: current_user.friends.order(:name) }
  end

  def show
    render json: { data: @friend }
  end

  def create
    friend = current_user.friends.new(friend_params)

    if friend.save
      render json: { data: friend }, status: :created
    else
      render_unprocessable(friend.errors.full_messages)
    end
  end

  def update
    if @friend.update(friend_params)
      render json: { data: @friend }
    else
      render_unprocessable(@friend.errors.full_messages)
    end
  end

  def destroy
    if @friend.destroy
      head :no_content
    else
      render_unprocessable(@friend.errors.full_messages)
    end
  end

  private

  def set_friend
    @friend = current_user.friends.find(params[:id])
  end

  def friend_params
    params.require(:friend).permit(:name, :email, :phone)
  end
end
