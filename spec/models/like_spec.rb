require 'rails_helper'

RSpec.describe Like, type: :model do
    describe 'associations' do
      it { should belong_to(:user) }
      it { should belong_to(:likable).counter_cache(true) }
    end

    describe 'validations' do
      subject { create(:like, :to_post) }

      it do
        should validate_uniqueness_of(:user_id)
          .scoped_to(:likable_id, :likable_type)
          .with_message('has already liked this')
      end
    end

    describe 'callbacks' do
      let(:user) { create(:user) }
      let(:post) { create(:post, user: user) }

      context 'when created' do
        it 'should increase user rating by 1' do
          expect {
            create(:like, likable: post)
          }.to change { user.reload.rating }.by(1)
        end
      end

      context 'when destroyed' do
        it 'should decrease user rating by 1' do
          like = create(:like, likable: post)
          expect {
            like.destroy
          }.to change { user.reload.rating }.by(-1)
        end
      end
    end
end
