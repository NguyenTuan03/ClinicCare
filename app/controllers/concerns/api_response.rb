module ApiResponse
  extend ActiveSupport::Concern

  def render_success(data:, message:, status: :ok)
    render json: {
      success: true,
      message: message,
      data: data
    }, status: status
  end

  def render_error(message:, status: :unprocessable_entity)
    render json: {
      success: false,
      message: message
    }, status: status
  end
end
