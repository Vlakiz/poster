class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true

  validates :body, length: { minimum: 3, maximum: 200 }

  paginates_per 15
end
