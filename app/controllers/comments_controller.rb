class CommentsController < ApplicationController
  class CommentableTypeError < StandardError; end

  before_action :find_commenter, only: :create
  before_action :set_comment, except: :create

  def create
    @comment = @commenter.comments.build(comments_params)
    respond_to do |format|
      if @comment.save
        format.json { render json: @comment }
      else
        format.json { render json: @comment.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def update
    @comment.update(comments_params) if current_user == @comment.user
    respond_to do |format|
      if @comment.errors.empty?
        format.json { render json: @comment }
      else
        format.json { render json: @comment.errors.full_messages }
      end
    end
  end

  def destroy
    @comment.destroy if current_user == @comment.user
  end

  private

  def find_commenter
    klass = [Question].detect { |c| params["#{c.name.underscore}_id"] }
    raise CommentableTypeError if klass.nil?

    @commenter = klass.find(params["#{klass.name.underscore}_id"])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comments_params
    params.require(:comment).permit(:body).merge(user: current_user)
  end
end
