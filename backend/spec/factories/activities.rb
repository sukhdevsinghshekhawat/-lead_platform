FactoryBot.define do
  factory :activity do
    lead
    user
    action { 'lead_created' }
    details { 'Lead was created' }
  end
end
