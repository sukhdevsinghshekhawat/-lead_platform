FactoryBot.define do
  factory :note do
    lead
    user
    message { Faker::Lorem.paragraph }
  end
end
