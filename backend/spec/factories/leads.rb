FactoryBot.define do
  factory :lead do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    phone { Faker::PhoneNumber.phone_number }
    company { Faker::Company.name }
    message { Faker::Lorem.paragraph }
    status { :new_lead }
    assigned_to { nil }

    trait :contacted do
      status { :contacted }
    end

    trait :qualified do
      status { :qualified }
    end

    trait :proposal_sent do
      status { :proposal_sent }
    end

    trait :won do
      status { :won }
    end

    trait :lost do
      status { :lost }
    end

    trait :with_assignment do
      assigned_to
    end
  end
end
