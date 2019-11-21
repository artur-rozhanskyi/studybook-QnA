class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  def index
    @questions = Question.all
    respond_with @questions
  end

  def show
    gon.user_id = current_user.id if current_user
    respond_with @question
  end

  def new
    @question = Question.new
    respond_with @question
  end

  def edit
    @question.attachments.build
  end

  def create
    @question = current_user.questions.create(question_params)
    question_cable @question, 'create' if @question.valid?
    respond_with @question
  end

  def update
    if current_user == @question.user
      question_cable @question, 'update' if @question.update(question_params)
    end
    respond_with @question
  end

  def destroy
    @question.destroy if current_user == @question.user
    question_cable @question, 'destroy' if @question.destroyed?
    respond_with @question
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
