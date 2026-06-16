puts "=== Khởi chạy nạp dữ liệu Seed ==="

Dir[Rails.root.join('db', 'seeds', '*.rb')].sort.each do |seed_file|
  puts "Đang nạp file seed: #{File.basename(seed_file)}..."
  load seed_file
end

puts "=== Hoàn thành nạp dữ liệu Seed! ==="
