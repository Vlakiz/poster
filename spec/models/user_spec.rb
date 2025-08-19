require 'rails_helper'

RSpec.describe User, type: :model do
    describe 'associations' do
        it { should have_many(:posts).with_foreign_key('author_id') }
        it { should have_many(:comments) }

        describe 'with likes' do
            it { should have_many(:likes).dependent(:destroy) }
            it { should have_many(:liked_posts).through(:likes).source(:likable) }
            it { should have_many(:liked_comments).through(:likes).source(:likable) }
        end

        describe 'with subscriptions' do
            it do
                should have_many(:passive_subscriptions)
                    .class_name('Subscription')
                    .with_foreign_key(:following_id)
                    .dependent(:destroy)
            end

            it do
                should have_many(:active_subscriptions)
                    .class_name('Subscription')
                    .with_foreign_key(:follower_id)
                    .dependent(:destroy)
            end

            it { should have_many(:followers).through(:passive_subscriptions).source(:follower) }
            it { should have_many(:followings).through(:active_subscriptions).source(:following) }
        end

        it { should have_one_attached(:avatar) }
    end

    describe 'enums' do
        it { should define_enum_for(:role).with_values([ :user, :moderator, :editor, :admin ]) }
    end

    describe 'validations' do
        require_relative '../support/shared_examples/models/user_shared_examples'

        subject { create(:user) }

        describe 'nickname' do
            it { should validate_presence_of(:nickname) }
            it { should validate_uniqueness_of(:nickname).case_insensitive }
            it { should validate_length_of(:nickname).is_at_least(3).is_at_most(30) }

            it "can't start with a number" do
                user = build(:user, nickname: '8ball')
                expect(user).not_to be_valid
                expect(user.errors[:nickname]).to include("should start with a letter and contain only "\
                                                          "letters, numbers or underscore (_)")
            end

            it "can't contain forbidden symbols" do
                user = build(:user, nickname: 'jonny$$$1337')
                expect(user).not_to be_valid
                expect(user.errors[:nickname]).to include("should start with a letter and contain only "\
                                                          "letters, numbers or underscore (_)")
            end

            it "should be valid if meets requirements" do
                user = build(:user, nickname: 'john_cena_2000')
                expect(user).to be_valid
            end
        end

        describe 'first_name' do
            include_examples 'name', :first_name
        end

        describe 'last_name' do
            include_examples 'name', :last_name
        end

        describe 'date_of_birth' do
            it { should validate_presence_of(:date_of_birth).on(:update) }

            it "should be valid if >= 14 years" do
                subject.update(date_of_birth: 14.years.ago)
                is_expected.to be_valid
            end

            it "should be invalud if < 14 years" do
                subject.update(date_of_birth: 13.years.ago)
                is_expected.not_to be_valid
                expect(subject.errors[:date_of_birth]).to include("must be at least 14 years old")
            end
        end

        describe 'signed_up_at' do
            it { should validate_presence_of(:signed_up_at).on(:update) }
        end

        describe 'country' do
            it { should validate_presence_of(:country).on(:update) }
            it { should validate_length_of(:country).is_equal_to(2).on(:update) }

            it "should be valid if exists" do
                subject.update(country: 'PL')
                is_expected.to be_valid
            end

            it "should be invalid if does not exist" do
                subject.update(country: 'QQ')
                is_expected.not_to be_valid
                expect(subject.errors[:country]).to include("is not a valid country")
            end
        end

        describe 'visible' do
            it { should validate_presence_of(:visible).with_message('can be either visible or not') }
        end
    end

    describe 'callbacks' do
        include ActiveSupport::Testing::TimeHelpers

        context 'when created' do
            let(:user) { create(:user, signed_up_at: nil) }

            it 'should set current registration date' do
                random_date = Faker::Time.backward(days: 365)
                travel_to random_date
                expect(user.signed_up_at).to eq(random_date)
            end

            it 'should be invisible' do
                expect(user.visible).to be_falsy
            end
        end
    end

    describe "pagination" do
        before(:each) { create_list(:user, 51) }
        let(:users) { User.all }

        it 'returns the right number of users on the first page' do
            expect(users.page(1).count).to be(50)
        end

        it 'returns the last user on the second page' do
            expect(users.page(2)).to eq([ users.last ])
        end

        it 'returns the right number of pages' do
            expect(users.page(1).total_pages).to be(2)
        end
    end

    describe "instance methods" do
        describe "#thumbnail" do
            let(:user) { build(:user, :with_avatar) }

            it "calls variant on avatar with specified size" do
                avatar = double(:avatar)
                allow(user).to receive(:avatar).and_return(avatar)

                size = 100
                expect(avatar).to receive(:variant).with(resize_to_fill: [ size, size ])
                user.thumbnail(size)
            end

            it "returns a variant" do
                variant = user.thumbnail(200)
                expect(variant).to be_a(ActiveStorage::VariantWithRecord)
            end

            context "when avatar is not present" do
                let(:user) { build(:user) }

                it "returns nil" do
                    nil_variant = user.thumbnail(300)
                    expect(nil_variant).to be_nil
                end
            end
        end

        describe "#follow!" do
            let(:users) { create_list(:user, 2) }

            context 'when following user exists and has not been followed' do
                it 'should create new subscription' do
                    expect {
                        users[0].follow!(users[1])
                    }.to change { Subscription.count }.by(1)
                end

                it 'should return subscription record with valid attributes' do
                    subscription = users[0].follow!(users[1])
                    expect(subscription.follower).to be(users[0])
                    expect(subscription.following).to be(users[1])
                end
            end

            context 'when user has already followed provided user' do
                before(:each) { users[0].follow!(users[1]) }

                it 'should not create any new subscription' do
                    expect {
                        users[0].follow!(users[1])
                    }.not_to change { Subscription.count }
                end

                it 'should add valid error message' do
                    result_subscription = users[0].follow!(users[1])

                    expect(result_subscription).not_to be_valid
                    expect(result_subscription.errors[:follower_id]).to include("are already following this user")
                end
            end

            context 'when user tries to follow himself' do
                it 'should not create any new subscription' do
                    expect {
                        users[0].follow!(users[0])
                    }.not_to change { Subscription.count }
                end

                it 'should add valid error messagw' do
                    result_subscription = users[0].follow!(users[0])

                    expect(result_subscription).not_to be_valid
                    expect(result_subscription.errors[:follower_id]).to include("can't follow yourself")
                end
            end

            context 'when following user is nil' do
                it 'should not create any new subscription' do
                    expect {
                        users[0].follow!(nil)
                    }.not_to change { Subscription.count }
                end
            end
        end

        describe "#unfollow!" do
            let(:users) { create_list(:user, 2) }

            context 'when provided user exists and has been followed' do
                before(:each) { users[0].follow!(users[1]) }

                it 'should destroy subscription' do
                    expect {
                        users[0].unfollow!(users[1])
                    }.to change { Subscription.count }.by(-1)
                end

                it 'should return a not persisted subscription' do
                    subscription = users[0].unfollow!(users[1])
                    expect(subscription).not_to be_persisted
                end
            end

            context 'when provided user is not followed' do
                include_examples 'invalid unfollow', { users_index: 1 }
            end

            context 'when user tries to unfollow himself' do
                include_examples 'invalid unfollow', { users_index: 0 }
            end

            context 'when provided user is nil' do
                include_examples 'invalid unfollow', { users_index: nil }
            end
        end

        describe "#followed_to?" do
            let(:users) { create_list(:user, 2) }

            context "user is following provided user" do
                before(:each) { users[0].follow!(users[1]) }

                it "should be truthy" do
                    result = users[0].followed_to?(users[1])
                    expect(result).to be_truthy
                end
            end

            context "user is not following provided user" do
                it "should be falsy" do
                    result = users[0].followed_to?(users[1])
                    expect(result).to be_falsy
                end
            end

            context "following user is nil" do
                it "should be falsy" do
                    result = users[0].followed_to?(nil)
                    expect(result).to be_falsy
                end
            end
        end
    end
end
