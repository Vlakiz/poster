module UsersHelper
    def avatar(user = @user, class_name: 'img-md')
        size = case class_name
            when /img-md/
                200
            when /img-lg/
                300
            when /img-sm/
                100
            when /img-xs/
                25
            end
        image = user.avatar.attached? ? user.avatar.variant(resize_to_limit: [size, size]) : "no-image.png"
        image_tag image, class: class_name
    end

    def full_name
        "#{@user.first_name} #{@user.last_name}"
    end

    def flag
        flag_url = "https://flagcdn.com/w20/#{@user.country.downcase}.png"
        image_tag flag_url, alt: @country_name
    end
end
