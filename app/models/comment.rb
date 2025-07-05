class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :body, length: { minimum: 3, maximum: 200 }

  paginates_per 15
end
