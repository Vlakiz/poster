require 'rails_helper'

RSpec.describe "posts/edit", type: :view do
    let(:post) { build_stubbed(:post) }

    before do
        assign(:post, post)
        render
    end

    subject { rendered }

    it "renders edit template" do
        is_expected.to have_selector("h1", text: "Editing post")
        is_expected.to have_selector("form")
    end

    it "renders input fields for nickname and avatar" do
        is_expected.to have_field("post_title")
        is_expected.to have_field("post_body")
    end

    it "has prepopulated fields" do
        is_expected.to have_field("post_title", with: post.title)
        is_expected.to have_field("post_body", with: post.body)
    end

    it "renders submit button" do
        is_expected.to have_button("Post")
    end

    it "forms correct action URL" do
        is_expected.to have_selector("form[action='#{post_path(post)}'][method='post']")
    end

    it "renders method patch" do
        is_expected.to have_selector("input[name='_method'][value='patch']", visible: false)
    end
end
