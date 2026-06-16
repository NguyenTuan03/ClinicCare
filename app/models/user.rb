class User < ApplicationRecord
  has_secure_password

  belongs_to :role
  has_many :schedules
  has_many :appointments

  validates :email, presence: true, uniqueness: true, format: {
    with: URI::MailTo::EMAIL_REGEXP
  }
  validates :password, presence: true
  validates :name, presence: true
end
