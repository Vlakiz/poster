module ApplicationHelper
    def resource_name
        :user
    end

    def resource
        @resource ||= User.new
    end

    def devise_mapping
        @devise_mapping ||= Devise.mappings[:user]
    end

    def days_ago_in_words(time)
        if time > 1.day.ago
            "today"
        elsif time > 2.days.ago
            "yesterday"
        else
            time_ago_in_words(time) + " ago"
        end
    end

    def sidebarable?
        %w[posts].include?(controller_name)
    end
end
