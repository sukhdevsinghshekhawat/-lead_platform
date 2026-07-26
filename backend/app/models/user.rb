class User < ApplicationRecord
  has_secure_password

  enum :role, { member: 0, admin: 1 }

  has_many :notes, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :assigned_leads, class_name: "Lead", foreign_key: "assigned_to_id", dependent: :nullify

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :role, presence: true

  scope :members, -> { where(role: :member) }
end
