class Lead < ApplicationRecord
  enum :status, { new_lead: 0, contacted: 1, qualified: 2, proposal_sent: 3, won: 4, lost: 5 }

  belongs_to :assigned_to, class_name: "User", optional: true
  has_many :notes, dependent: :destroy
  has_many :activities, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_assigned_user, ->(user_id) { where(assigned_to_id: user_id) if user_id.present? }
  scope :search, ->(query) {
    return all if query.blank?
    where("name ILIKE :q OR email ILIKE :q OR company ILIKE :q OR phone ILIKE :q", q: "%#{query}%")
  }
  scope :newest_first, -> { order(created_at: :desc) }
end
