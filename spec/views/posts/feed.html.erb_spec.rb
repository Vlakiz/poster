require 'rails_helper'

RSpec.describe "posts/feed", type: :view do
    let(:posts) { build_stubbed_list(:post, 3) }

    subject { rendered }

    context "when there are posts" do
        before do
            posts_double = double("posts", next_page: nil, any?: true)
            chain = allow(posts_double).to receive(:each)
            posts.each { |p| chain = chain.and_yield(p) }

            assign(:posts, posts_double)
            allow(view).to receive(:user_signed_in?).and_return(true)
            allow(view).to receive(:current_user).and_return(build_stubbed(:user, visible: true))
            render
        end

        it "displays the posts" do
            posts.each do |post|
                is_expected.to have_content(post.title)
                is_expected.to have_content(post.body[0..30])
            end
        end

        context "and they don't have next page" do
            it "does not display next page link" do
                is_expected.not_to have_selector('[data-testid="next_page_link"]')
            end
        end
    end

    context "when there are no posts" do
        before do
            assign(:posts, double("posts", any?: false))
            render
        end

        it "displays no posts message" do
            is_expected.to have_selector("h4", text: "No posts available")
        end

        it "does not display next page link" do
            is_expected.not_to have_selector('[data-testid="next_page_link"]')
        end
    end

    context "when posts have next page" do
        before do
            assign(:posts, double("posts", any?: true, next_page: 3).as_null_object)
            assign(:filter, { feed: 'new' })
            render
        end

        describe "next page link" do
            subject { Capybara.string(rendered).find('[data-testid="next_page_link"]') }

            let(:href) { subject[:href] }

            it "is present" do
                is_expected.to be_present
            end

            it "have the same filter" do
                expect(href).to include("new")
            end

            it "have correct next page number" do
                expect(href).to include("page=3")
            end
        end
    end
end
