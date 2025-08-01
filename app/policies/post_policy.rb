class PostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    @user&.visible?
  end

  def update?
    @user&.visible? && (@record.user == @user || @user.admin? || @user.editor?)
  end

  def destroy?
    @user&.visible? && (@record.user == @user || @user.admin? || @user.editor?)
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
