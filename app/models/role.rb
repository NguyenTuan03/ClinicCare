class Role < ApplicationRecord
  has_many :users

  enum :name, { patient: "patient", doctor: "doctor", admin: "admin", super_admin: "super_admin" }
end
