class Post < ApplicationRecord
    belongs_to :user, class_name: "User", foreign_key: :author_id
    has_many :comments, dependent: :destroy
    has_many :likes, as: :likable, dependent: :destroy
    has_many :liking_users, through: :likes, source: :user

    validates :title, length: { minimum: 5, maximum: 50 }
    validates :body, length: { minimum: 15, maximum: 1000 }

    before_save :generate_random_seed

    scope :random, ->(seed) { order(Arel.sql("ABS(random_seed - #{seed.to_f})")) }
    scope :from_user, ->(user_id) { where(author_id: user_id) }
    scope :fresh, ->() { order(published_at: :desc) }
    scope :best, ->() { order(likes_count: :desc) }
    scope :subscriptions, ->(user) { where(author_id: user.followings) }

    paginates_per 10

    private

    def generate_random_seed
        self.random_seed = rand
    end
end
