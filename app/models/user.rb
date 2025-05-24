class User < ApplicationRecord
    has_many :posts, class_name: 'Post', foreign_key: 'author_id'
    has_many :comments

    validates :login, presence: true, uniqueness: true

    paginates_per 50
end
