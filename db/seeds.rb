# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Cleaning database..."
Comment.destroy_all
Post.destroy_all
User.destroy_all
if Rails.env.development?
    ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name = 'users'")
end


puts "Creating users..."
10.times do
    password = Faker::Internet.password(min_length: 8)
    user_attributes = {
        email: Faker::Internet.unique.email,
        nickname: Faker::Internet.unique.username(specifier: 7..25, separators: [ '_' ]),
        password: password,
        password_confirmation: password,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        date_of_birth: Faker::Date.birthday(min_age: 16, max_age: 65),
        signed_up_at: Faker::Date.backward(days: 365),
        country: Faker::Address.country_code
    }
    user = User.new(user_attributes)
    if user.save
        puts "User created: #{user.nickname}:#{password}"
    else
        puts "Error creating user: #{user.errors.full_messages.join(', ')}"
    end
end


puts "Creating posts..."
30.times do |i|
    post_attributes = {
        title: Faker::Book.title,
        body: Faker::Lorem.paragraphs(number: rand(1..15)).join("\n\n"),
        author_id: rand(0...10),
        published_at: i.days.from_now
    }
    post = Post.new(post_attributes)
    if post.save
        comments_count = rand(0..7)
        comments_count.times do
            comment_attributes = {
                body: Faker::Quote.jack_handey,
                post_id: post.id,
                user_id: rand(0...10)
            }
            comment = Comment.new(comment_attributes)
            comment.save
        end
        puts "Post created: #{post.title} along with #{comments_count} comments"
    else
        puts "Error creating post: #{post.errors.full_messages.join(', ')}"
    end
end
