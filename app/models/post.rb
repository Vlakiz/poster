class Post < ApplicationRecord
    belongs_to :user, class_name: 'User', foreign_key: 'author_id'
    has_many :comments, dependent: :destroy

    validates :title, presence: true, length: { minimum: 5 }
    validates :body, presence: true, length: { minimum: 50 }
end
