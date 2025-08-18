FactoryBot.define do
  factory :post do
    user
    title { Faker::Book.title }
    body { Faker::Lorem.paragraphs(number: rand(1..10)) }

    trait :randomly_created_at do
      published_at { Faker::Time.backward(days: 365) }
    end

    trait :randomly_liked do
      likes_count { (rand() * 1000).to_i }
    end
  end
end
