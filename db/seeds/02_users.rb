# db/seeds/02_users.rb
puts "Đang tạo dữ liệu User..."

doctor_role = Role.find_by!(name: 'doctor')
patient_role = Role.find_by!(name: 'patient')

# Danh sách Bác sĩ mẫu
doctors_data = [
  { email: 'doctor.albert@clinic.com', name: 'Dr. Albert Einstein' },
  { email: 'doctor.marie@clinic.com', name: 'Dr. Marie Curie' },
  { email: 'doctor.feynman@clinic.com', name: 'Dr. Richard Feynman' }
]

# Danh sách Bệnh nhân mẫu
patients_data = [
  { email: 'patient.tuan@gmail.com', name: 'Nguyễn Văn Tuấn' },
  { email: 'patient.hoa@gmail.com', name: 'Lê Thị Hoa' },
  { email: 'patient.nam@gmail.com', name: 'Trần Hoàng Nam' }
]

def create_user(data, role)
  User.find_or_create_by!(email: data[:email]) do |user|
    user.name = data[:name]
    user.role = role

    # Kiểm tra động để gán mật khẩu an toàn
    if user.respond_to?(:password=)
      user.password = 'password123'
    else
      # Nếu chưa khai báo has_secure_password trong model User, gán hash mật khẩu giả định vào password_digest
      user.password_digest = "$2a$12$uq4R7mDqXmK.D56u6Z72EuS1c4l6y8Rj1sH3H6QW8W/Z8e3Vl.xK2" # bcrypt hash của 'password123'
    end
  end
end

doctors_data.each { |doc| create_user(doc, doctor_role) }
patients_data.each { |pat| create_user(pat, patient_role) }

puts "Hoàn thành tạo User! Tổng số Bác sĩ: #{User.where(role: doctor_role).count}, Bệnh nhân: #{User.where(role: patient_role).count}"
