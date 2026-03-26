class ApplicationController < ActionController::API
	rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

	attr_reader :current_user

	private

	def authenticate_user!
		token = request.headers["Authorization"]&.split(" ")&.last
		return render_unauthorized("Missing token") if token.blank?

		begin
			payload = JWT.decode(token, jwt_secret, true, { algorithm: "HS256" }).first
			@current_user = User.find(payload["user_id"])
		rescue JWT::DecodeError, ActiveRecord::RecordNotFound
			render_unauthorized("Invalid token")
		end
	end

	def jwt_secret
		ENV["JWT_SECRET"] || Rails.application.credentials.secret_key_base || "dev_secret_change_me"
	end

	def encode_token(payload)
		JWT.encode(payload, jwt_secret, "HS256")
	end

	def render_unprocessable(errors)
		render json: { error: "validation_error", details: errors }, status: :unprocessable_entity
	end

	def render_not_found(error = nil)
		message = error&.message || "Resource not found"
		render json: { error: "not_found", message: message }, status: :not_found
	end

	def render_unauthorized(message = "Unauthorized")
		render json: { error: "unauthorized", message: message }, status: :unauthorized
	end
end
