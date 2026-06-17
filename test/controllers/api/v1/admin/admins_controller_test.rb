require "test_helper"

class Api::V1::Admin::AdminsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Xoá toàn bộ dữ liệu kiểm thử cũ để tránh xung đột
    User.destroy_all
    Role.destroy_all

    @patient_role = Role.create!(name: :patient)
    @doctor_role = Role.create!(name: :doctor)
    @admin_role = Role.create!(name: :admin)
    @super_admin_role = Role.create!(name: :super_admin)

    @patient = User.create!(email: "patient@test.com", password: "password123", name: "Patient User", role: @patient_role)
    @doctor = User.create!(email: "doctor@test.com", password: "password123", name: "Doctor User", role: @doctor_role)
    @admin = User.create!(email: "admin@test.com", password: "password123", name: "Admin User", role: @admin_role)
    @super_admin = User.create!(email: "super_admin@test.com", password: "password123", name: "Super Admin User", role: @super_admin_role)

    @admin_token = JsonWebToken.encode(user_id: @admin.id)
    @super_admin_token = JsonWebToken.encode(user_id: @super_admin.id)
    @patient_token = JsonWebToken.encode(user_id: @patient.id)
    @doctor_token = JsonWebToken.encode(user_id: @doctor.id)
  end

  test "should deny access if token is missing" do
    post api_v1_admin_create_account_url, params: { email: "new_doc@test.com", password: "password123", name: "New Doctor", role: "doctor" }
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal false, json_response["success"]
    assert_equal "Authorization token is missing", json_response["message"]
  end

  test "should deny access for patient role" do
    post api_v1_admin_create_account_url,
         params: { email: "new_doc@test.com", password: "password123", name: "New Doctor", role: "doctor" },
         headers: { "Authorization" => "Bearer #{@patient_token}" }
    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal false, json_response["success"]
    assert_equal "Access denied. Admin privileges required.", json_response["message"]
  end

  test "should deny access for doctor role" do
    post api_v1_admin_create_account_url,
         params: { email: "new_doc@test.com", password: "password123", name: "New Doctor", role: "doctor" },
         headers: { "Authorization" => "Bearer #{@doctor_token}" }
    assert_response :forbidden
  end

  test "should allow admin to create doctor account" do
    assert_difference "User.count", 1 do
      post api_v1_admin_create_account_url,
           params: { email: "new_doc@test.com", password: "password123", name: "New Doctor", role: "doctor" },
           headers: { "Authorization" => "Bearer #{@admin_token}" }
    end
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal true, json_response["success"]
    assert_equal "Account created successfully", json_response["message"]
    assert_equal "new_doc@test.com", json_response["data"]["email"]
    assert_equal "doctor", json_response["data"]["role"]
  end

  test "should allow super_admin to create admin account" do
    assert_difference "User.count", 1 do
      post api_v1_admin_create_account_url,
           params: { email: "new_sub_admin@test.com", password: "password123", name: "New Sub Admin", role: "admin" },
           headers: { "Authorization" => "Bearer #{@super_admin_token}" }
    end
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "admin", json_response["data"]["role"]
  end

  test "should fail if role is invalid" do
    post api_v1_admin_create_account_url,
         params: { email: "new_doc@test.com", password: "password123", name: "New Doctor", role: "invalid_role" },
         headers: { "Authorization" => "Bearer #{@admin_token}" }
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "Invalid role specified", json_response["message"]
  end

  test "should fail if email is missing or invalid" do
    post api_v1_admin_create_account_url,
         params: { email: "", password: "password123", name: "New Doctor", role: "doctor" },
         headers: { "Authorization" => "Bearer #{@admin_token}" }
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["message"], "Email can't be blank"
  end
end
