class Api::V1::Admin::AdminsController < ApplicationController
  before_action :authorize_request
  before_action :authorize_admin!

  # POST /api/v1/admin/create-account
  def create_account
    role_name = params[:role]

    # Kiểm tra tính hợp lệ dựa trên Enum có sẵn trong Model Role (tránh hardcode)
    unless Role.names.key?(role_name)
      return render_error(message: "Invalid role specified", status: :unprocessable_entity)
    end

    role = Role.find_by(name: role_name)
    if role.nil?
      return render_error(message: "Role not found", status: :not_found)
    end

    user = User.new(user_params)
    user.role = role

    if user.save
      data_return = {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role.name
      }
      render_success(data: data_return, message: "Account created successfully", status: :created)
    else
      render_error(message: user.errors.full_messages, status: :unprocessable_entity)
    end
  end

  private

  def authorize_admin!
    # Cho phép cả admin và super_admin truy cập
    unless @current_user&.role&.admin? || @current_user&.role&.super_admin?
      render_error(message: "Access denied. Admin privileges required.", status: :forbidden)
    end
  end

  def user_params
    params.permit(:email, :password, :name)
  end
end
