class CatchJsonParseErrors
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue ActionDispatch::Http::Parameters::ParseError => error
      # Kiểm tra nếu request yêu cầu JSON hoặc gửi lên JSON
      if env["CONTENT_TYPE"] =~ /application\/json/ || env["HTTP_ACCEPT"] =~ /application\/json/
        [
          400,
          { "Content-Type" => "application/json; charset=utf-8" },
          [ { success: false, message: "Malformed JSON payload: #{error.message}" }.to_json ]
        ]
      else
        raise error
      end
    end
  end
end
