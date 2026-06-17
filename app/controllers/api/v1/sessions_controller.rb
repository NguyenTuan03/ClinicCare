class Api::V1::SessionsController < ApplicationController
  def register
    user = User.new(user_params)

    # Gán role mặc định là 'patient'
    user.role = Role.patient.first

    data_return = {
      name: user.name,
      email: user.email,
      role: user.role.name
    }

    if user.save
      render_success(data: data_return, message: "User registered successfully", status: :created)
    else
      render_error(message: user.errors.full_messages, status: :unprocessable_entity)
    end
  end

  def login
    user = User.find_by(email: params[:email])

    # Early return nếu thông tin đăng nhập không chính xác
    if user.nil? || !user.authenticate(params[:password])
      return render_error(message: "Invalid email or password", status: :unauthorized)
    end

    token = JsonWebToken.encode(user_id: user.id)
    time = 24.hours.from_now

    data_return = {
      token: token,
      exp: time.to_i,
      user: { id: user.id, email: user.email, role: user.role.name, name: user.name }
    }

    render_success(data: data_return, message: "User logged in successfully", status: :ok)
  end

  private

  def user_params
    permitted = params.permit(:email, :password, :name)
    permitted[:password] = permitted[:password].to_s if permitted[:password].present?
    permitted
  end
end
