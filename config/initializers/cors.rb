Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Đọc danh sách domain từ biến môi trường ALLOWED_ORIGINS, phân tách bằng dấu phẩy.
    # Nếu không cấu hình (như ở local), mặc định cho phép các cổng localhost để tiện phát triển.
    allowed_origins = ENV.fetch("ALLOWED_ORIGINS") do
      "http://localhost:8386,http://127.0.0.1:8386,http://localhost:3000,http://localhost:3001"
    end.split(",")

    origins(*allowed_origins)

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
