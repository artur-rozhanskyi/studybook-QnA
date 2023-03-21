class QuestionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def subscribe?
    true unless user&.question_subscribed?(record)
  end

  def unsubscribe?
    true if user&.question_subscribed?(record)
  end

  def best?
    owner?
  end
end
