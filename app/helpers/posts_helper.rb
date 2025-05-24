module PostsHelper
    def format_date(date)
        date.in_time_zone('Warsaw').to_date
    end
end
