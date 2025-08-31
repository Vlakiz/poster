require 'rails_helper'

RSpec.describe CommentPolicy, type: :policy do
  let (:visible_user) { build_stubbed(:user, visible: true) }
  let (:invisible_user) { build_stubbed(:user, visible: false) }
  let(:comment) { build_stubbed(:comment) }

  subject { described_class }

  permissions :index? do
    it { should permit }
  end

  permissions :show? do
    it { should permit }
  end

  permissions :create? do
    it { should permit(visible_user) }
    it { should_not permit(invisible_user) }
  end

  context 'when user is not the author of the comment' do
    permissions :update?, :destroy? do
      it { should_not permit(visible_user, comment) }
    end
  end

  context 'when user is the author of the comment' do
    let(:user) { build_stubbed(:user, visible: true) }
    let(:comment) { build_stubbed(:comment, user: user) }

    permissions :update?, :destroy? do
      it { should permit(user, comment) }
    end
  end

  context 'when user is an editor' do
    let(:user) { build_stubbed(:user, :editor, visible: true) }
    let(:comment) { build_stubbed(:comment) }

    permissions :update?, :destroy? do
      it { should permit(user, comment) }
    end
  end

  context 'when user is an moderator' do
    let(:user) { build_stubbed(:user, :moderator, visible: true) }

    permissions :update?, :destroy? do
      it { should permit(user, comment) }
    end
  end

  context 'when user is an admin' do
    let(:user) { build_stubbed(:user, :admin, visible: true) }

    permissions :update?, :destroy? do
      it { should permit(user, comment) }
    end
  end
end
