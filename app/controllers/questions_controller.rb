class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  def index
    @questions = Question.all
  end

  def show; end

  def new
    @question = Question.new
  end

  def edit; end

  def create
    @question = Question.new(question_params)
    @question.save ? redirect_to(@question) : render(:new)
  end

  def update
    @question.update(question_params) ? redirect_to(@question) : render(:edit)
  end

  def destroy
    @question.destroy
    redirect_to questions_path
  end

  private

  def set_question
    @question = Question.find params[:id]
  end

  def question_params
    params.require(:question).permit(:title, :body)
  end
end
