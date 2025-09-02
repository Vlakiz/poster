require 'rails_helper'

RSpec.describe SubscriptionPolicy, type: :policy do
  subject { described_class }

  let (:visible_user) { build_stubbed(:user, visible: true) }
  let (:invisible_user) { build_stubbed(:user, visible: false) }

  permissions :destroy?, :create? do
    it { should_not permit(invisible_user) }
    it { should permit(visible_user) }
  end
end
