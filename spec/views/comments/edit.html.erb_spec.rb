require 'rails_helper'

RSpec.describe "comments/edit", type: :view do
    let(:post) { build_stubbed(:post) }
    let(:replied_comment) { build_stubbed(:comment, post: post) }
    let(:comment) { build_stubbed(:comment, replied_to: replied_comment, post: post) }

    before do
        assign(:comment, comment)
        allow(view).to receive(:action_name).and_return('edit')
        render
    end

    subject { rendered }

    it "renders edit template" do
        is_expected.to have_selector("h4", text: "Editing comment")
        is_expected.to have_selector("form")
    end

    it "have prepopulated input with comment body" do
        is_expected.to have_field("comment_body", with: comment.body)
    end

    it "renders submit button" do
        is_expected.to have_button("Edit")
    end

    it "renders cancel button" do
        is_expected.to have_button("Cancel")
    end

    it "forms correct action URL" do
        is_expected.to have_selector("form[action='#{comment_path(comment)}'][method='post']")
    end

    it "renders method patch" do
        is_expected.to have_selector("input[name='_method'][value='patch']", visible: false)
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
