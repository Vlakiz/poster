require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  let (:visible_user) { build_stubbed(:user, visible: true) }
  let (:invisible_user) { build_stubbed(:user, visible: false) }

  subject { described_class }

  permissions :show? do
    it { should permit }
  end

  permissions :new_profile?, :create_profile? do
    it { should_not permit(visible_user) }
    it { should permit(invisible_user) }
  end

  permissions :remove_avatar?, :update? do
    let(:admin) { build_stubbed(:user, :admin, visible: true) }

    it { should_not permit(invisible_user) }
    it { should_not permit(visible_user) }
    it { should permit(admin) }
    it { should permit(visible_user, visible_user) }
    it { should_not permit(invisible_user, invisible_user) }
  end
end
