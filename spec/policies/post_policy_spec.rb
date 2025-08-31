require 'rails_helper'

RSpec.describe PostPolicy, type: :policy do
  let (:visible_user) { build_stubbed(:user, visible: true) }
  let (:invisible_user) { build_stubbed(:user, visible: false) }
  let(:post) { build_stubbed(:post) }

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

  context 'when user is not the author of the post' do
    permissions :update?, :destroy? do
      it { should_not permit(visible_user, post) }
    end
  end

  context 'when user is the author of the post' do
    let(:user) { build_stubbed(:user, visible: true) }
    let(:post) { build_stubbed(:post, user: user) }

    permissions :update?, :destroy? do
      it { should permit(user, post) }
    end
  end

  context 'when user is an editor' do
    let(:user) { build_stubbed(:user, :editor, visible: true) }
    let(:post) { build_stubbed(:post) }

    permissions :update?, :destroy? do
      it { should permit(user, post) }
    end
  end

  context 'when user is an moderator' do
    let(:user) { build_stubbed(:user, :moderator, visible: true) }

    permissions :update?, :destroy? do
      it { should_not permit(user, post) }
    end
  end

  context 'when user is an admin' do
    let(:user) { build_stubbed(:user, :admin, visible: true) }

    permissions :update?, :destroy? do
      it { should permit(user, post) }
    end
  end
end
