class Post < ApplicationRecord
    belongs_to :user, class_name: "User", foreign_key: "author_id"
    has_many :comments, dependent: :destroy

    validates :title, length: { minimum: 5 }
    validates :body, length: { minimum: 15 }

    scope :random, -> { order("RANDOM()") }
    scope :from_user, ->(user_id) { where(author_id: user_id) }

    paginates_per 10
end
