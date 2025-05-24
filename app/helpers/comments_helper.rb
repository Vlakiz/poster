module CommentsHelper
    def format_comment_date(date)
        date.in_time_zone('Warsaw').strftime("%F %T")
    end
end
