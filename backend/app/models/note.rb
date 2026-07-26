class Note < ApplicationRecord
  belongs_to :user
  belongs_to :lead

  validates :message, presence: true

  scope :newest_first, -> { order(created_at: :desc) }
end
