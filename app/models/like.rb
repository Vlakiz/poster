class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likable, polymorphic: true, counter_cache: true

  validates :user_id, uniqueness: { scope: [ :likable_id, :likable_type ], message: "has already liked this" }

  after_create :increment_user_rating
  after_destroy :decrement_user_rating

  def increment_user_rating
    likable.user.increment!(:rating)
  end

  def decrement_user_rating
    likable.user.decrement!(:rating)
  end
end
