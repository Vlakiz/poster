class Post < ApplicationRecord
    belongs_to :user, class_name: "User", foreign_key: "author_id"
    has_many :comments, dependent: :destroy
    has_many :likes, as: :likable, dependent: :destroy
    has_many :liking_users, through: :likes, source: :user

    validates :title, length: { minimum: 5, maximum: 50 }
    validates :body, length: { minimum: 15, maximum: 1000 }

    scope :random, -> { order("RANDOM()") }
    scope :from_user, ->(user_id) { where(author_id: user_id) }

    paginates_per 10
end
