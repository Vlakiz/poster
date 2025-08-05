class SubscriptionPolicy < ApplicationPolicy
  def destroy?
    @user&.visible?
  end

  def create?
    @user&.visible?
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
