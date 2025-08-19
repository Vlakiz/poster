FactoryBot.define do
  factory :comment, aliases: [ :reply ] do
    user
    post
    body { Faker::Lorem.paragraphs(number: rand(1..2)) }

    trait :is_reply do
      after(:build) do |reply|
        reply.replied_to ||= build(:comment, post: reply.post)
      end
    end
  end
end
