class UserPolicy < ApplicationPolicy
  def show?
    true # @user
  end

  def new_profile?
    create_profile?
  end

  def create_profile?
    @user && !@user.visible?
  end

  def remove_avatar?
    @user && (@record == @user || @user.admin?)
  end

  def update?
    @user && (@record == @user || @user.admin?)
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
