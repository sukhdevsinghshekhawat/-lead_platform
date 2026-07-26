class Activity < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :lead

  validates :action, presence: true

  scope :newest_first, -> { order(created_at: :desc) }
end
