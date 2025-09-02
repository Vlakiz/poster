require 'rails_helper'

RSpec.describe "users/edit", type: :view do
    let(:user) { build_stubbed(:user) }

    before do
        assign(:user, user)
    end

    subject { rendered }

    it "renders edit template" do
        render

        is_expected.to have_selector("h2", text: "Edit profile")
        is_expected.to have_selector("form")
    end

    it "renders input field for nickname and avatar" do
        render

        is_expected.to have_field("user_nickname")
        is_expected.to have_field("user_avatar")
    end

    it "renders submit button" do
        render

        is_expected.to have_button("Update User")
    end

    context "when user has an avatar" do
        before do
            allow(user.avatar).to receive(:attached?).and_return(true)
            allow(user).to receive(:thumbnail).and_return("/path/to/avatar_thumbnail.png")
        end

        it "displays the avatar image" do
            render

            is_expected.to have_xpath("//img[contains(@src,'avatar_thumbnail.png')]")
        end

        it "displays delete avatar button" do
            render

            is_expected.to have_selector('a', text: 'Delete avatar')
        end
    end

    context "when user has no avatar" do
        it "does not display the avatar image" do
            render

            is_expected.not_to have_xpath("//img[contains(@src,'avatar.png')]")
        end

        it "does not display delete avatar button" do
            render

            is_expected.not_to have_selector('a', text: 'Delete avatar')
        end
    end
end
