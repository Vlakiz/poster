FactoryBot.define do
  factory :user, aliases: [ :author, :following, :follower ] do
    sequence(:email) { |n| "user#{n}@example.com" }

    nickname { Faker::Internet.unique.username(specifier: 7..25, separators: [ '_' ]) }
    password { "password123" }
    password_confirmation { "password123" }
    signed_up_at { Faker::Time.backward(days: 30) }

    trait :with_avatar do
      after(:build) do |user|
        user.avatar.attach(
          io: File.open(Rails.root.join("spec", "factories", "files", "avatar.png")),
          filename: "avatar.png",
          content_type: "image/png"
        )
      end
    end

    trait :visible do
      visible { true }
    end

    trait :invisible do
      visible { false }
    end
  end
end
