class Api::V1::AuthController < ApplicationController
  before_action :authenticate_user!, only: [:me]

  def register
    user = User.new(register_params)

    if user.save
      token = encode_token({ user_id: user.id })
      render json: { token: token, user: user.slice(:id, :name, :email) }, status: :created
    else
      render_unprocessable(user.errors.full_messages)
    end
  end

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = encode_token({ user_id: user.id })
      render json: { token: token, user: user.slice(:id, :name, :email) }
    else
      render_unauthorized("Invalid credentials")
    end
  end

  def me
    render json: { user: current_user.slice(:id, :name, :email) }
  end

  private

  def register_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
