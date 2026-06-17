class JsonWebToken
  # Use Rails application secret key base for signing the token
  SECRET_KEY = Rails.application.secret_key_base

  # Encode data into a JWT token with an expiration time
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  # Decode a token and return the payload, or nil if invalid/expired
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError
    nil
  end
end
