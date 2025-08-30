module Likable
  extend ActiveSupport::Concern

  included do
    has_many :likes, as: :likable, dependent: :destroy
    has_many :liking_users, through: :likes, source: :user
    has_many :preview_likes, -> { order(created_at: :desc).limit(5) }, as: :likable, class_name: "Like"

    scope :with_user_like, ->(user) do
      if user
        select(sanitize_sql_array([
          "?.*, EXISTS(SELECT 1 FROM likes WHERE likes.likable_type = ?"\
          " AND likes.likable_id = ?.id AND likes.user_id = ?) AS liked",
          table_name, name, table_name, user.id
        ]))
      else
        all
      end
    end

    def liked?(user = nil)
      if respond_to?(:liked)
        liked == 1
      else
        likes.exists?(user: user)
      end
    end
  end
end
