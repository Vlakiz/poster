require 'rails_helper'

RSpec.describe Likable, type: :model do
  before do
    class DummyModel < ApplicationRecord
      self.table_name = "posts"
      include Likable

      def user
      end
    end
  end

  after do
    Object.send(:remove_const, :DummyModel)
  end

  let(:user) { create(:user) }

  subject do
    DummyModel.create!(title: "test title", body: "test body", author_id: user.id)
  end

  describe "associations" do
    it { should have_many(:likes).dependent(:destroy) }
    it { should have_many(:liking_users).through(:likes).source(:user) }
    it { should have_many(:preview_likes).order(created_at: :desc).class_name('Like') }
  end

  describe "scopes" do
    before do
      3.times do
        DummyModel.create!(title: "test", body: "xxxxxxxxxx", author_id: user.id)
      end

      another_user = create(:user)

      3.times do
        DummyModel.create!(title: "test", body: "xxxxxxxxxx", author_id: another_user.id)
      end
    end

    after do
      DummyModel.destroy_all
      User.destroy_all
    end

    describe ".with_user_like" do
      context 'when user is provided' do
        let(:objects) { DummyModel.all.with_user_like(user) }

        it "should return the right count of likable objects" do
          expect(objects.to_a.count).to eq(6)
        end

        it "should return objects with new attribute liked" do
          expect(objects).to all(respond_to(:liked))
        end

        context "when user has liked likable object" do
          it "should return collection with one liked object" do
            create(:like, user: user, likable: subject)

            liked_objects = objects.to_a.select { |x| x.liked == 1 }
            expect(liked_objects.count).to eq(1)
          end
        end

        context "when user hasn't liked likable object" do
          it "should return collection with 0 liked objects" do
            liked_objects = objects.to_a.select { |x| x.liked == 1 }
            expect(liked_objects.count).to eq(0)
          end
        end
      end

      context 'when nil is provided' do
          it "should return objects without attribute liked" do
            objects = DummyModel.all.with_user_like(nil)
            expect(objects).to be_none { |o| o.respond_to?(:liked) }
          end
      end
    end
  end

  describe "instance methods" do
    describe "#liked?" do
      let(:liked_object) { DummyModel.create!(title: "test", body: "xxxxxxxxxx", author_id: user.id) }
      before(:each) { create(:like, user: user, likable: liked_object) }

      context 'when with_user_like was used' do
        let(:last_created_object) { DummyModel.all.with_user_like(user).last }

        it 'should not call method likes' do
          expect(last_created_object).not_to receive(:likes)
          last_created_object.liked?(user)
        end

        it 'should be true if liked' do
          expect(last_created_object).to be_liked
        end

        it 'should be false if not liked' do
          DummyModel.create!(title: "test", body: "xxxxxxxxxx", author_id: user.id)
          expect(last_created_object).not_to be_liked
        end
      end

      context 'when with_user_like was not used' do
        it 'should call method exists? on likes with user' do
          likes_double = double(:likes)
          allow(liked_object).to receive(:likes).and_return(likes_double)

          expect(liked_object.likes).to receive(:exists?).with(user: user)
          liked_object.liked?(user)
        end

        it 'should be true if liked' do
          expect(liked_object.liked?(user)).to be_truthy
        end

        it 'should be false if not liked' do
          not_liked_object = DummyModel.create!(title: "test", body: "xxxxxxxxxx", author_id: user.id)
          expect(not_liked_object.liked?(user)).to be_falsy
        end
      end
    end
  end
end
