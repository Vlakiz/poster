require 'rails_helper'

RSpec.describe "comments/index", type: :view do
    let(:post) { build_stubbed(:post) }
    let(:comments) { build_stubbed_list(:comment, 7, post: post) }
    let(:order) { 'newer' }
    let(:next_page) { nil }
    let(:prev_page) { nil }

    subject { rendered }

    context "when comments are present" do
        before do
            comments_double = double("comments", next_page: next_page, prev_page: prev_page, any?: true)
            chain = allow(comments_double).to receive(:each)
            comments.each { |c| chain = chain.and_yield(c) }

            assign(:comments, comments_double)
            assign(:order, order)
            assign(:post_id, post.id)
            allow(view).to receive(:user_signed_in?).and_return(true)
            allow(view).to receive(:current_user).and_return(build_stubbed(:user, visible: true))
        end

        it "does not display no comments message" do
            render
            is_expected.not_to have_content("No comments on the post yet")
        end

        it "displays comments collection" do
            render
            is_expected.to have_selector("[data-testid='comments']")
        end

        it "displays the posts" do
            render
            comments.each do |comment|
                is_expected.to have_content(comment.body[0..30])
            end
        end

        describe "sort button" do
            before { render }

            it "is present" do
                is_expected.to have_button("Sort by")
            end

            describe "options" do
                it "has best option" do
                    is_expected.to have_link("Best", href: post_comments_path(post_id: post.id, order: 'rating'))
                end

                it "has newest option" do
                    is_expected.to have_link("Newest", href: post_comments_path(post_id: post.id, order: 'newer'))
                end

                it "has oldest option" do
                    is_expected.to have_link("Oldest", href: post_comments_path(post_id: post.id, order: 'older'))
                end
            end
        end

        context "and they don't have next page" do
            it "does not display next page link" do
                is_expected.not_to have_selector(id: 'comments_next_page')
            end
        end

        context "and they have next page" do
            let(:next_page) { 7 }

            before do
                render
            end

            it "displays next page link" do
                is_expected.to have_selector(id: 'comments_next_page')
            end

            it "links to correct page number" do
                is_expected.to have_link(href: post_comments_path(post_id: post.id, page: next_page, order: order))
            end
        end

        context "and they have prev page" do
            let(:prev_page) { 2 }

            before do
                render
            end

            it "does not display sort button" do
                is_expected.not_to have_button("Sort by")
            end
        end
    end

    context "when comments are not present" do
        before do
            assign(:comments, double("comments", any?: false, first_page?: true))
            render
        end

        it "displays no comments message" do
            is_expected.to have_content("No comments on the post yet")
        end

        it "does not display sort button" do
            is_expected.not_to have_button("Sort by")
        end

        it "does not display comments collection" do
            is_expected.not_to have_selector("[data-testid='comments']")
        end
    end
end
