module CommentsHelper
    def format_comment_date(date)
        date.in_time_zone("Warsaw").strftime("%F %T")
    end

    def modified?(comment)
        comment.created_at != comment.updated_at
    end

    def ats_to_links(body)
        body.gsub(/(?<=p>)@(\w+)(?=,)/) do
            link_to($~, nickname_path($1),
                    class: "link-underline link-underline-opacity-0 text-danger",
                    data: { turbo_frame: "_top" })
        end.html_safe
    end
end
