require 'rails_helper'

RSpec.describe "posts/show", type: :view do
    let(:current_user) { build_stubbed(:user, :with_avatar) }
    let(:user) { build_stubbed(:user, :with_avatar) }
    let(:post) { build_stubbed(:post, :randomly_liked, user: user, published_at: 1.month.ago) }
    let(:comment_order) { "newest" }

    before do
        assign(:post, post)
        assign(:new_comment, Comment.new(user: current_user, post: post))
        assign(:comments_order, comment_order)
        assign(:preview_likes, [])
        allow(view).to receive(:current_user).and_return(current_user)
        allow(view).to receive(:user_signed_in?).and_return(true)
    end

    subject { rendered }

    describe "rendered post" do
        it "have title" do
            render
            is_expected.to have_content(post.title)
        end

        it "have body" do
            render
            is_expected.to have_content(post.body)
        end

        it "have correct published date" do
            render
            is_expected.to have_content('about 1 month ago')
        end

        it "have author's nickname" do
            render
            is_expected.to have_content('@' + user.nickname)
        end

        it "have like button" do
            render
            is_expected.to have_button(class: "like")
        end

        it "have comments section" do
            render
            is_expected.to have_selector("#comments")
        end

        it "displays turbo frame with the comments in the right order" do
            render
            src = post_comments_path(post_id: post.id, order: comment_order)
            is_expected.to have_selector("turbo-frame[src='#{src}']")
        end

        describe "comments count link" do
            let(:comments_count) { 5 }

            before do
                allow(post).to receive(:comments_count).and_return(comments_count)
                render
            end

            subject { Capybara.string(rendered).find('[data-testid="comments_count"]') }

            it { is_expected.to be_present }

            it "is expected to contain comments count" do
                expect(subject).to have_content(comments_count)
            end

            it "links to comments section" do
                expect(subject[:href]).to eq(post_path(post, anchor: 'comments'))
            end
        end

        describe "author's avatar" do
            context "when it's present" do
                let(:path) { "/path/to/avatar_thumbnail.png" }

                before do
                    allow(user).to receive(:avatar).and_return(double(attached?: true))
                    allow(user).to receive(:thumbnail).and_return(path)
                    render
                end

                it "shows author's avatar" do
                    is_expected.to have_xpath("//img[contains(@src,'#{path}')]")
                end
            end

            context "when it's not present" do
                before do
                    allow(user).to receive(:avatar).and_return(double(attached?: false))
                    render
                end

                it "shows default avatar" do
                    is_expected.to have_xpath("//img[contains(@src,'no-image')]")
                end
            end
        end

        context "when user is logged in" do
            before do
                allow(view).to receive(:user_signed_in?).and_return(true)
                render
            end

            it "shows new comment form" do
                is_expected.to have_selector("[data-testid='new_comment_form']")
            end

            it "does not prompt user to sign in" do
                is_expected.not_to have_link("sign in", href: new_user_session_path)
                is_expected.not_to have_content("to leave a comment")
            end
        end

        context "when user is not logged in" do
            before do
                allow(view).to receive(:user_signed_in?).and_return(false)
                render
            end

            it "shows new comment form" do
                is_expected.not_to have_selector("[data-testid='new_comment_form']")
            end

            it "prompts user to sign in" do
                is_expected.to have_link("sign in", href: new_user_session_path)
                is_expected.to have_content("to leave a comment")
            end
        end

        context "when author is not current user" do
            before { render }

            it "does not show edit post link" do
                is_expected.not_to have_link('Edit post', href: edit_post_path(post))
            end

            it "does not show delete post link" do
                is_expected.not_to have_button('Delete post')
            end
        end

        context "when author is current user" do
            let(:user) { current_user }

            before { render }

            it "shows edit post link" do
                is_expected.to have_link('Edit post', href: edit_post_path(post))
            end

            it "shows delete post link" do
                is_expected.to have_button('Delete post')
            end
        end
    end
end
