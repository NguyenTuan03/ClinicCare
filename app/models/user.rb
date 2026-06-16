class User < ApplicationRecord
  belongs_to :role
  has_many :schedules
  has_many :appointments
end
