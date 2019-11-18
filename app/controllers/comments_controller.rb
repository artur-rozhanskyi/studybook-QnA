class CommentsController < ApplicationController
  class CommentableTypeError < StandardError; end

  before_action :find_commenter, only: :create
  before_action :set_comment, except: :create

  def create
    @comment = @commenter.comments.build(comments_params)
    if @comment.save
      comment_cable @comment, 'create'
      render body: nil
    else
      render json: @comment.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    @comment.update(comments_params) if current_user == @comment.user
    if @comment.errors.empty?
      comment_cable @comment, 'update'
      render body: nil
    else
      render json: @comment.errors.full_messages
    end
  end

  def destroy
    @comment.destroy if current_user == @comment.user
    return unless @comment.destroyed?

    comment_cable @comment, 'destroy'
    render body: nil
  end

  private

  def find_commenter
    klass = [Answer, Question].detect { |c| params["#{c.name.underscore}_id"] }
    raise CommentableTypeError if klass.nil?

    @commenter = klass.find(params["#{klass.name.underscore}_id"])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comments_params
    params.require(:comment).permit(:body).merge(user: current_user)
  end

  def comment_cable(comment, action)
    ActionCable.server.broadcast(
      'question/comments',
      { comment: comment, action: action }.as_json
    )
  end
end
