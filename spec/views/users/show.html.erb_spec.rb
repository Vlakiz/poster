require 'rails_helper'

RSpec.describe "users/show", type: :view do
    let(:user) { build_stubbed(:user, :with_avatar, :visible, country: 'FR', nickname: "johndoe",
                               first_name: "John", last_name: "Doe", signed_up_at: 1.month.ago) }
    let(:logged_in_user) { build_stubbed(:user, :visible, :with_avatar) }
    let(:country_name) { "France" }

    before do
        posts = build_stubbed_list(:post, 5, user: user)
        posts_double = double("posts", next_page: nil, any?: true)
        chain = allow(posts_double).to receive(:each)
        posts.each { |p| chain = chain.and_yield(p) }

        assign(:posts, posts_double)
        assign(:user, user)
        assign(:country_name, country_name)

        allow(view).to receive(:current_user).and_return(logged_in_user)
        allow(view).to receive(:user_signed_in?).and_return(true)
    end

    context "when user is not the current user" do
        context "and has posts" do
            before { render }

            it "displays the user's full name" do
                expect(rendered).to have_selector("h4", text: "#{user.first_name} #{user.last_name}")
            end

            it "displays the user's nickname" do
                expect(rendered).to have_content(user.nickname)
            end

            it "displays the user's country with flag" do
                expect(rendered).to have_content(country_name)
                expect(rendered).to have_xpath('//img[contains(@src, "flagcdn.com/w20/fr.png")]')
            end

            it "displays correct registration date" do
                expect(rendered).to have_content("Joined about 1 month ago")
            end

            it "displays the user's avatar" do
                expect(rendered).to have_xpath("//img[contains(@src, '#{user.thumbnail(200)}')]")
            end

            it "displays the user's posts" do
                expect(rendered).to have_selector('#user-posts')
                expect(rendered).to have_selector('.post-wrapper', count: 5)
            end

            it "displays follow button" do
                expect(rendered).to have_selector('button', text: 'Follow')
            end

            it "does not display edit button" do
                expect(rendered).not_to have_selector('a', text: 'Edit profile')
            end

            it "does not display upload avatar button" do
                expect(rendered).not_to have_xpath('//input[@value="Upload new avatar"]')
            end

            it "does not have button to delete avatar" do
                expect(rendered).not_to have_selector('a', text: 'Delete avatar')
            end
        end

        context "and has no avatar" do
            before do
                allow(user).to receive(:avatar).and_return(double(attached?: false))
                render
            end

            it "displays default avatar" do
                expect(rendered).to have_xpath("//img[contains(@src, 'no-image')]")
            end
        end

        context "and is not visible" do
            before do
                allow(user).to receive(:visible?).and_return(false)
                render
            end

            it "does not display button to create profile" do
                expect(rendered).not_to have_selector('a', text: 'Create profile')
            end

            it "displays message to fill profile" do
                expect(rendered).to have_content("The user has not been completed information about himself")
            end
        end

        context "and has no posts" do
            before do
                assign(:posts, double("posts", next_page: nil, any?: false))
                render
            end

            it "displays no posts message" do
                expect(rendered).to have_content("User does not have any posts")
            end
        end
    end

    context "when user is the current user" do
        before do
            assign(:user, logged_in_user)
        end

        it "does not display follow button" do
            render
            expect(rendered).not_to have_selector('button', text: 'Follow')
        end

        it "displays edit button" do
            render
            expect(rendered).to have_selector('a', text: 'Edit profile')
        end

        it "displays upload avatar button" do
            render
            expect(rendered).to have_xpath('//input[@value="Upload new avatar"]')
        end

        context "and has an avatar" do
            before do
                allow(logged_in_user).to receive(:avatar).and_return(double(attached?: true, variant: nil, thumbnail: nil))
                allow(logged_in_user).to receive(:thumbnail).with(200).and_return("/path/to/avatar_thumbnail.png")
            end

            it "displays button to delete avatar" do
                render
                expect(rendered).to have_selector('a', text: 'Delete current avatar')
            end
        end

        context "and is not visible" do
            before do
                allow(logged_in_user).to receive(:visible?).and_return(false)
                render
            end

            it "displays button to create profile" do
                expect(rendered).to have_selector('a', text: 'Create profile')
            end

            it "displays message to fill profile" do
                expect(rendered).to have_content("Please fill your personal details")
            end
        end

        context "and has no posts" do
            before do
                assign(:posts, double("posts", next_page: nil, any?: false))
                render
            end

            it "displays no posts message" do
                expect(rendered).to have_content("You don't have any posts yet. Write your first!")
            end
        end
    end
end
