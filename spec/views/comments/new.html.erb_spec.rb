require 'rails_helper'

RSpec.describe "comments/new", type: :view do
    let(:user) { build_stubbed(:user) }
    let(:post) { build_stubbed(:post) }
    let(:replied_comment) { build_stubbed(:comment, post: post) }
    let(:comment) { Comment.new(replied_to: replied_comment, post: post, user: user) }

    before do
        assign(:comment, comment)
        allow(view).to receive(:action_name).and_return('new')
        render
    end

    subject { rendered }

    it "renders new comment's form" do
        is_expected.to have_selector("form")
    end

    it "renders submit button" do
        is_expected.to have_button("Comment")
    end

    it "renders cancel button" do
        is_expected.to have_button("Cancel")
    end

    it "forms correct action URL" do
        is_expected.to have_selector("form[action='#{post_comments_path(post)}'][method='post']")
    end

    it "does not render method patch" do
        is_expected.not_to have_selector("input[name='_method'][value='patch']", visible: false)
    end

    describe "comment author's avatar" do
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

    describe "hidden fields" do
        it "has hidden field for user_id" do
            is_expected.to have_field("comment_user_id", type: "hidden", with: comment.user_id, visible: false)
        end

        it "has hidden field for post_id" do
            is_expected.to have_field("comment_post_id", type: "hidden", with: comment.post_id, visible: false)
        end

        it "has hidden field for replied_to_id" do
            is_expected.to have_field("comment_replied_to_id", type: "hidden", with: comment.replied_to_id, visible: false)
        end
    end
end
