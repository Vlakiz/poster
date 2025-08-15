module Likable
  extend ActiveSupport::Concern

  included do
    has_many :likes, as: :likable, dependent: :destroy
    has_many :liking_users, through: :likes, source: :user
    has_many :preview_likes, -> { order(created_at: :desc).limit(5) }, as: :likable, class_name: "Like"

    scope :includes_user_like, ->(user) do
        if user
            join_sql = sanitize_sql_array([
              "LEFT OUTER JOIN likes"\
              " ON likes.likable_type = ?"\
              " AND likes.likable_id = #{table_name}.id"\
              " AND likes.user_id = ?",
              name, user.id
            ])
            joins(join_sql)
              .select("#{table_name}.*, likable_id as like")
        else
            all
        end
    end
  end

  def liked?(user = nil)
    if respond_to?(:like)
        like.present?
    else
        likes.exists?(user: user)
    end
  end
end
