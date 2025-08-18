FactoryBot.define do
  factory :like do
    user
    to_post

    trait :to_post do
      association :likable, factory: :post
    end

    trait :to_comment do
      association :likable, factory: :comment
    end
  end
end
