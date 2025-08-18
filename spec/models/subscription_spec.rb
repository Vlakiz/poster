require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'associations' do
    it { should belong_to(:follower).counter_cache(:followings_count) }
    it { should belong_to(:following).counter_cache(:followers_count) }
  end

  describe 'validations' do
    subject { create(:subscription) }

    it { should validate_uniqueness_of(:follower_id).scoped_to(:following_id) }

    context 'when following differs from follower' do
      it 'should be valid' do
        following_user, follower_user = create_list(:user, 2)
        subscription = build(:subscription,
                              following: following_user,
                              follower: follower_user,)
        expect(subscription).to be_valid
      end
    end

    context 'when following is equal to follower' do
      let(:user) { create(:user) }
      subject { build(:subscription, following: user, follower: user) }

      it { should_not be_valid }
      it "should add error message cant follow yourself" do
        subject.valid?
        expect(subject.errors[:follower_id]).to include("can't follow yourself")
      end
    end
  end
end
