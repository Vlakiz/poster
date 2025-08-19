require 'rails_helper'

RSpec.describe Comment, type: :model do
    describe 'included concerns' do
        it { expect(Post).to include(Likable) }
    end

    describe 'associations' do
        it { should belong_to(:user) }
        it { should belong_to(:post).counter_cache(true) }

        it do
            should have_many(:replies)
                .class_name("Comment")
                .with_foreign_key("replied_to_id")
                .dependent(:destroy)
        end

        it do
            should belong_to(:replied_to)
                .class_name("Comment")
                .optional
                .counter_cache(:replies_count)
        end
    end

    describe 'validations' do
        it { should validate_length_of(:body).is_at_least(3).is_at_most(200) }

        context "when it is a reply" do
            let(:post) { create(:post) }
            let(:comment_for_reply) { create(:comment, post: post) }

            context "when it is replied to a comment from another post" do
                subject { build(:reply, replied_to: comment_for_reply) }

                it { is_expected.not_to be_valid }

                it "should add a proper error message" do
                    subject.valid?
                    expect(subject.errors[:body]).to include("replies to the comment from another post")
                end
            end

            context "when it is replied to a comment from the same post" do
                subject { build(:reply, replied_to: comment_for_reply, post: post) }

                it { is_expected.to be_valid }
            end

            context "when it is replied to another reply" do
                let(:reply) { create(:reply, replied_to: comment_for_reply, post: post) }
                subject { build(:reply, replied_to: reply, post: post) }

                it { is_expected.not_to be_valid }

                it "should add a proper error message" do
                    subject.valid?
                    expect(subject.errors[:body]).to include("can't reply to a reply")
                end
            end
        end
    end

    describe 'callbacks' do
        it "should strip body after create" do
            raw_body = "  need  to\n\n  be stripped  "
            comment = create(:comment, body: raw_body)
            expect(comment.body).to eq(raw_body.strip)
        end
    end

    describe 'scopes' do
        let(:post) { create(:post) }
        let(:comment_for_reply) { create(:comment, post: post) }

        before(:each) { create_list(:reply, 3, replied_to: comment_for_reply, post: post) }
        before(:each) { create_list(:comment, 3) }
        before(:each) { create_list(:reply, 3, :is_reply) }

        describe '.not_replies' do
            it 'should only include comments that are not replies' do
                comments = Comment.all.not_replies
                expect(comments.size).to be(7)
                expect(comments).to all(have_attributes(replied_to: nil))
            end
        end

        describe '.replying_to' do
            it 'should only include replies to a specified comment' do
                replies = Comment.all.replying_to(comment_for_reply)
                expect(replies.size).to be(3)
                expect(replies).to all(have_attributes(replied_to: comment_for_reply))
            end
        end
    end

    describe 'pagination' do
        before(:each) { create_list(:comment, 30) }
        let(:comments) { Comment.all }

        it 'returns the right number of posts on the first page' do
            expect(comments.page(1).count).to be(10)
        end

        it 'returns the next posts on the second page' do
            expect(comments.page(2)).to eq(comments[10...20])
        end

        it 'returns the right number of pages' do
            expect(comments.page(1).total_pages).to be(3)
        end
    end
end
