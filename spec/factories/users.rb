FactoryBot.define do
  factory :user, aliases: [ :author ] do
    sequence(:email) { |n| "user#{n}@example.com" }

    nickname { Faker::Internet.unique.username(specifier: 7..25, separators: [ '_' ]) }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
