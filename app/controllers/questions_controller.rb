class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  def index
    @questions = Question.all
  end

  def show
    gon.user_id = current_user.id if current_user
    @question.answers.map(&:attachments).map(&:build)
    @answer = @question.answers.build
    @comment = @question.comments.build
    @answer.attachments.build
  end

  def new
    @question = Question.new
    @question.attachments.build
  end

  def edit
    @question.attachments.build
  end

  def create
    @question = current_user.questions.build(question_params)
    if @question.save
      question_cable @question, 'create'
      redirect_to(@question)
    else
      render :new
    end
  end

  def update
    if current_user == @question.user
      if @question.update(question_params)
        question_cable @question, 'update'
        redirect_to(@question)
      else
        render(:edit)
      end
    else
      redirect_to questions_path, alert: 'You don`t have permission'
    end
  end

  def destroy
    @question.destroy if current_user == @question.user
    return unless @question.destroyed?

    question_cable @question, 'destroy'
    redirect_to questions_path, notice: 'Your question was deleted successfully'
  end

  private

  def set_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :body, attachments_attributes: [:file, :remove_file, :id, :_destroy])
  end

  def question_cable(question, action)
    ActionCable.server.broadcast(
      'questions',
      { question: QuestionSerializer.new(question), action: action }.as_json
    )
  end
end
