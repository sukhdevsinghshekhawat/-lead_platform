FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { :member }

    trait :admin do
      role { :admin }
    end

    trait :member do
      role { :member }
    end
  end
end
