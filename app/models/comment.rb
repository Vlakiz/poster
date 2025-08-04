class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true
  has_many :likes, as: :likable, dependent: :destroy
  has_many :liking_users, through: :likes, source: :user

  validates :body, length: { minimum: 3, maximum: 200 }

  paginates_per 5
end
