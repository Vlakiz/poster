module LikesHelper
  def liked?(likable)
    method = case likable
    when Post
               :liked_posts
    when Comment
               :liked_comments
    else
               nil
    end
    raise "Invalid likable type: #{likable.class.name}" unless method

    current_user&.send(method)&.include?(likable)
  end
end
