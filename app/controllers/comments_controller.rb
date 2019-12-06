class CommentsController < ApplicationController
  class CommentableTypeError < StandardError; end

  before_action :find_commenter, only: :create
  before_action :set_comment, except: :create

  respond_to :json, :js

  def create
    @comment = @commenter.comments.build(comments_params)
    authorize @comment
    comment_cable @comment, 'create' if @comment.save
    respond_with @comment
  end

  def update
    authorize @comment
    @comment.update(comments_params)
    comment_cable @comment, 'update' if @comment.valid?
    respond_with @comment
  end

  def destroy
    authorize @comment
    @comment.destroy
    comment_cable @comment, 'destroy' if @comment.destroyed?
    respond_with @comment
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
