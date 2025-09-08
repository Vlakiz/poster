require 'rails_helper'

RSpec.describe "comments/show", type: :view do
    let(:user) { build_stubbed(:user, :with_avatar) }
    let(:current_user) { build_stubbed(:user) }
    let(:created_at) { 1.month.ago }
    let(:updated_at) { created_at }
    let(:replies_count) { 67 }
    let(:comment) { build_stubbed(:comment, updated_at: updated_at, user: user,
                                  created_at: created_at, replies_count: replies_count,) }

    before do
        assign(:comment, comment)
        allow(view).to receive(:current_user).and_return(current_user)
        allow(view).to receive(:user_signed_in?).and_return(true)
    end

    subject { rendered }

    it "renders comment's body" do
        render
        is_expected.to have_content(comment.body)
    end

    it "renders correct published date" do
        render
        is_expected.to have_content('about 1 month ago')
    end

    it "renders like button" do
        render
        is_expected.to have_button(class: "like")
    end

    it "renders reply button" do
        render
        is_expected.to have_link('Reply')
    end

    it "renders reply frame" do
        render
        is_expected.to have_selector('turbo-frame', id: "#{dom_id comment}_new_reply_frame")
    end

    describe "comment's author" do
        before { render }

        it "has avatar" do
            is_expected.to have_selector('.comment-avatar > img')
        end

        it "has nickname" do
            is_expected.to have_content('@' + user.nickname)
        end

        it "linked with to author's page" do
            is_expected.to have_link(href: user_path(user))
        end
    end

    context "when comment was not edited" do
        it "does not render edited label" do
            render
            is_expected.not_to have_content('edited')
        end
    end

    context "when comment was edited" do
        let(:updated_at) { 1.week.ago }

        it "renders edited label" do
            render
            is_expected.to have_content('edited')
        end
    end

    context "when author is not current user" do
        before { render }

        it { is_expected.not_to have_link 'Edit' }
        it { is_expected.not_to have_link 'Delete' }
    end

    context "when author is current user" do
        let(:current_user) { user }
        before { render }

        it { is_expected.to have_link 'Edit' }
        it { is_expected.to have_link 'Delete' }
    end

    context "when comment is not a reply" do
        before do
            allow(comment).to receive(:is_reply?).and_return(false)
        end

        it "has replies count" do
            render
            is_expected.to have_selector('div', class: 'replies-count', text: replies_count)
        end

        it "renders container for replies' next page" do
            render
            is_expected.to have_selector('div', id: "comment_#{comment.id}_replies_next_page")
        end

        context "and has replies" do
            before { render }

            it { is_expected.to have_link('Show replies', href: comment_replies_path(comment_id: comment.id)) }

            it "renders replies frame" do
                render
                is_expected.to have_selector('turbo-frame', id: "#{dom_id comment}_replies_frame")
            end
        end

        context "and has no replies" do
            before do
                allow(comment).to receive(:replies).and_return(double('replies', any?: false))
                render
            end

            it { is_expected.not_to have_link('Show replies') }

            it "does not render replies frame" do
                render
                is_expected.not_to have_selector('turbo-frame', id: "#{dom_id comment}_replies_frame")
            end
        end
    end

    context "when comment is a reply" do
        before do
            allow(comment).to receive(:is_reply?).and_return(true)
            render
        end

        it { is_expected.not_to have_selector('div', class: 'replies-count') }
        it { is_expected.not_to have_link('Show replies') }

        it "does not render container for replies' next page" do
            is_expected.not_to have_selector('div', id: "comment_#{comment.id}_replies_next_page")
        end
    end
end
