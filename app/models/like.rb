class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likable, polymorphic: true, counter_cache: true

  validates :user_id, uniqueness: { scope: [:likable_id, :likable_type], message: 'has already liked this' }
end
