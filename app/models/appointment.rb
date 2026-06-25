class Appointment < ApplicationRecord
  enum :status, { pending: "pending", confirmed: "confirmed", cancelled: "cancelled" }
  belongs_to :patient, class_name: "User"
  belongs_to :schedule
end
