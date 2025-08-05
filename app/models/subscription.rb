class Subscription < ApplicationRecord
  belongs_to :follower, class_name: "User", counter_cache: :followers_count
  belongs_to :following, class_name: "User", counter_cache: :followings_count

  validates :follower_id, uniqueness: { scope: :following_id }

  validate :cant_follow_to_yourself

  private

  def cant_follow_to_yourself
    if follower_id == following_id
      errors.add(:follower_id, "can't follow yourself")
    end
  end
end
