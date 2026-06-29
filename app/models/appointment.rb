class Appointment < ApplicationRecord
  enum :status, { pending: "pending", confirmed: "confirmed", cancelled: "cancelled", done: "done" }
  belongs_to :patient, class_name: "User"
  belongs_to :schedule
end
