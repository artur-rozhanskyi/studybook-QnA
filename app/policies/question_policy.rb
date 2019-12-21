class QuestionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def subscribe?
    true
  end

  def unsubscribe?
    true
  end
end
