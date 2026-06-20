class Schedule < ApplicationRecord
  belongs_to :user
  has_many :appointments

  validates :date, :start_time, :end_time, presence: true
  validate :date_format_must_be_valid
  validate :time_format_must_be_valid

  private

  def date_format_must_be_valid
    raw_date = date_before_type_cast
    return if raw_date.blank?
    # Sử dụng Regex và Date.strptime để kiểm tra tính hợp lệ
    is_valid = raw_date.to_s.match?(/\A\d{4}-\d{2}-\d{2}\z/) && 
                (Date.strptime(raw_date.to_s, '%Y-%m-%d') rescue false)
    return if is_valid
    errors.add(:date, "phải đúng định dạng YYYY-MM-DD và là ngày hợp lệ")
  end
  
  # Validate định dạng Time (HH:MM)
  def time_format_must_be_valid
    # Áp dụng tương tự cho start_time và end_time
    [:start_time, :end_time].each do |attr|
      raw_val = send("#{attr}_before_type_cast")
      return if raw_val.blank?
      # Kiểm tra định dạng HH:MM (24 giờ)
      is_valid = raw_val.to_s.match?(/\A([01]\d|2[0-3]):[0-5]\d\z/)
      
      next if is_valid
      errors.add(attr, "phải đúng định dạng HH:MM")
    end
  end
end
