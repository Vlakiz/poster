module PostsHelper
    def format_post_date(date)
        date.in_time_zone("Warsaw").to_date.inspect
    end

    def liked?(post)
        current_user&.liked_posts&.include?(post)
    end
end
