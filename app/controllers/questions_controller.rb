class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  def index
    @questions = Question.all
  end

  def show
    @answer = @question.answers.build
  end

  def new
    @question = Question.new
    @question.attachments.build
  end

  def edit; end

  def create
    @question = current_user.questions.build(question_params)
    @question.save ? redirect_to(@question) : render(:new)
  end

  def update
    if current_user == @question.user
      @question.update(question_params) ? redirect_to(@question) : render(:edit)
    else
      redirect_to(questions_path) { flash[:error] = 'You don`t have permission' }
    end
  end

  def destroy
    @question.destroy if current_user == @question.user
    redirect_to questions_path
  end

  private

  def set_question
    @question = Question.find params[:id]
  end

  def question_params
    params.require(:question).permit(:title, :body, attachments_attributes: [:file, :remove_file, :id, :_destroy])
  end
end
