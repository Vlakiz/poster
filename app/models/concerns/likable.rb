module Likable
  extend ActiveSupport::Concern

  included do
    has_many :likes, as: :likable, dependent: :destroy
    has_many :liking_users, through: :likes, source: :user

    scope :includes_user_like, ->(user) do
        if user
            joins('LEFT OUTER JOIN likes'\
                  " ON likes.likable_type = \'#{name}\'"\
                  " AND likes.likable_id = #{table_name}.id"\
                  " AND likes.user_id = #{user.id}")
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