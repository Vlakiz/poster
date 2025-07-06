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
end
