require 'rails_helper'

RSpec.describe "posts/new", type: :view do
    let(:post) { Post.new }

    before do
        assign(:post, post)
        render
    end

    subject { rendered }

    it "renders edit template" do
        is_expected.to have_selector("h1", text: "New post")
        is_expected.to have_selector("form")
    end

    it "renders input fields for nickname and avatar" do
        is_expected.to have_field("post_title")
        is_expected.to have_field("post_body")
    end

    it "renders submit button" do
        is_expected.to have_button("Post")
    end

    it "forms correct action URL" do
        is_expected.to have_selector("form[action='#{posts_path}'][method='post']")
    end

    it "does not render method patch" do
        is_expected.not_to have_selector("input[name='_method'][value='patch']", visible: false)
    end
end
