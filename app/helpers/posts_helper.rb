module PostsHelper
    def format_post_date(date)
        date.in_time_zone("Warsaw").to_date.inspect
    end
end
