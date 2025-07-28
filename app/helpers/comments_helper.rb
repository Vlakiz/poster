module CommentsHelper
    def format_comment_date(date)
        date.in_time_zone("Warsaw").strftime("%F %T")
    end

    def modified?(comment)
        comment.created_at != comment.updated_at
    end
end
