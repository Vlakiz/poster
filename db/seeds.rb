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
User.destroy_all
if Rails.env.development?
    ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name = 'users'");
end
Comment.destroy_all
Post.destroy_all


puts 'Creating users...'
10.times do
    password = Faker::Internet.password(min_length: 8);
    user_attributes = {
        email: Faker::Internet.unique.email,
        nickname: Faker::Internet.unique.username(specifier: 7..25),
        password: password,
        password_confirmation: password,
    }
    user = User.new(user_attributes);
    if (user.save)
        puts "User created: #{user.nickname}"
    else
        puts "Error creating user: #{user.errors.full_messages.join(', ')}"
    end
end


puts 'Creating posts...'
10.times do |i|
    post_attributes = {
        title: Faker::Book.title,
        body: Faker::Lorem.paragraph,
        author_id: 1 + (rand() * 10).floor,
        published_at: i.days.from_now,
    }
    post = Post.new(post_attributes);
    if (post.save)
        puts "Post created: #{post.title}"
    else
        puts "Error creating post: #{post.errors.full_messages.join(', ')}"
    end
end