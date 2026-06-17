puts "Đang tạo dữ liệu Role..."

[ 'doctor', 'patient', 'admin', 'super_admin' ].each do |role_name|
  Role.find_or_create_by!(name: role_name)
end

puts "Hoàn thành tạo Role: #{Role.pluck(:name).join(', ')}"
