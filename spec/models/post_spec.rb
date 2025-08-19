require 'rails_helper'

RSpec.describe Post, type: :model do
    describe 'included concerns' do
        it { expect(Post).to include(Likable) }
    end

    describe 'associations' do
        it { should belong_to(:user) }
        it { should have_many(:comments).dependent(:destroy) }
    end

    describe 'validations' do
        it { should validate_length_of(:title).is_at_least(5).is_at_most(50) }
        it { should validate_length_of(:body).is_at_least(15).is_at_most(1000) }
    end

    describe 'callbacks' do
        it 'should generate random seed on create' do
            post = create(:post, random_seed: nil)
            expect(post.random_seed).not_to be(nil)
        end
    end

    describe 'scopes' do
        describe '.random' do
            before (:each) { create_list(:post, 10) }

            context "when seed is the same" do
                it 'order in returned collection should be the same' do
                    seed = rand.round(5)

                    random_list1 = Post.random(seed)
                    random_list2 = Post.random(seed)

                    expect(random_list1).to eq(random_list2)
                end
            end

            context "when seed is different" do
                it 'order returned collection should differ' do
                    random_list1 = Post.random(0.4)
                    random_list2 = Post.random(0.7)

                    expect(random_list1).not_to eq(random_list2)
                end
            end
        end


        describe '.from_user' do
            it 'should return posts only from provided user' do
                users = create_list(:user, 3)

                create_list(:post, 3, user: users[0])
                create_list(:post, 3, user: users[1])
                create_list(:post, 3, user: users[2])

                user_list = Post.from_user(users[1].id)

                expect(user_list.size).to be(3)
                expect(user_list).to all(have_attributes(user: users[1]))
            end
        end


        describe '.fresh' do
            it 'should return newest posts ordered by date of publication' do
                create_list(:post, 5, :randomly_created_at)

                published_dates = Post.fresh.pluck(:published_at)

                expect(published_dates).to eq(published_dates.sort.reverse)
            end
        end


        describe '.best' do
            it 'should return the most liked posts in discending order' do
                create_list(:post, 5, :randomly_liked)

                post_likes = Post.best.pluck(:likes_count)

                expect(post_likes).to eq(post_likes.sort.reverse)
            end
        end


        describe '.subscriptions' do
            it 'should return posts only from the following users' do
                users = create_list(:user, 4)
                current_user = users[0]

                current_user.follow!(users[1])
                current_user.follow!(users[2])

                users.each do |user|
                    create_list(:post, 3, user: user)
                end

                following_users_posts = users[1].posts + users[2].posts
                subscription_posts = Post.subscriptions(current_user)

                expect(subscription_posts).to match_array(following_users_posts)
            end
        end
    end

    describe "pagination" do
        before(:each) { create_list(:post, 30) }
        let(:posts) { Post.all }

        it 'returns the right number of posts on the first page' do
            expect(posts.page(1).count).to be(10)
        end

        it 'returns the next posts on the second page' do
            expect(posts.page(2)).to eq(posts[10...20])
        end

        it 'returns the right number of pages' do
            expect(posts.page(1).total_pages).to be(3)
        end
    end

    describe "instance methods" do
        describe "#published?" do
            let(:post) { build(:post) }

            it 'expect not to be published by default' do
                expect(post).not_to be_published
            end

            it 'expect be truthy if post has published_at' do
                post.published_at = Time.now

                expect(post).to be_published
            end
        end

        describe "#publish!" do
            include ActiveSupport::Testing::TimeHelpers

            it 'sets published_at to current time' do
                post = build(:post)

                random_time = Faker::Time.backward
                travel_to random_time

                post.publish!

                expect(post.published_at).to eq(random_time)
            end

            it 'throws an error if published_at is present' do
                post = build(:post)
                post.publish!
                expect { post.publish! }.to raise_error("Post is already published")
            end
        end
    end
end
