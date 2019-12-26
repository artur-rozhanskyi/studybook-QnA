class CommentPresenter < BasePresenter
  def commenter
    case commentable
    when Answer
      commentable.question
    when Question
      commentable
    end
  end
end
