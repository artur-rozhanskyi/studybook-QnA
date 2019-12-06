class ProfilePolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    user.present?
  end

  def new?
    false
  end

  def create?
    false
  end

  def update?
    owner?
  end

  def edit?
    owner?
  end

  def destroy?
    false
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
