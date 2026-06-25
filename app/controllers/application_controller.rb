class ApplicationController < ActionController::API
  include ApiResponse
  include Pundit::Authorization

  # Centrally rescue JSON formatting/parsing errors from client
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :render_bad_request

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authorize_request
    header = request.headers["Authorization"]
    header = header.split(" ").last if header

    # Early return nếu không có token
    if header.blank?
      return render_error(message: "Authorization token is missing", status: :unauthorized)
    end

    @decoded = JsonWebToken.decode(header)

    # Early return nếu token không hợp lệ hoặc hết hạn (JsonWebToken.decode trả về nil)
    if @decoded.nil?
      return render_error(message: "Token is invalid or expired", status: :unauthorized)
    end

    begin
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound
      render_error(message: "User not found", status: :unauthorized)
    end
  end

  def current_user
    @current_user
  end

  private

  def render_bad_request(exception)
    render_error(message: "Malformed JSON payload in request body", status: :bad_request)
  end

  def user_not_authorized
    render_error(message: "You don't have permission to perform this action", status: :forbidden)
  end
end
