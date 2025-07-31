json.post do
  json.id post.id
  json.url post_url(post)
  json.title post.title
  json.body post.body
  json.published_at post.published_at
  json.likes_count post.likes_count
  json.comments_count post.comments_count
  json.user do |user|
    json.id post.user.id
    json.url user_url(post.user)
    json.nickname post.user.nickname
  end
end
