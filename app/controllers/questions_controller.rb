class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @questions = Question.all
    respond_with @questions
  end

  def show
    gon.user_id = current_user.id if current_user
    @new_answer = AnswerForm.new Answer.new
    @question_answers = @question.answers.map { |answer| AnswerForm.new answer }
    respond_with @question
  end

  def new
    @question = Question.new
    respond_with @question
  end

  def edit
    respond_with @question
  end

  def create
    @question_form = QuestionForm.new
    authorize @question_form
    question_cable @question_form, 'create' if @question_form.submit(question_params.merge(user: current_user))
    respond_with @question_form
  end

  def update
    @question_form = QuestionForm.new(@question)
    authorize @question_form
    question_cable @question_form, 'update' if @question_form.submit(question_params.merge(user: current_user))
    respond_with @question_form
  end

  def destroy
    authorize @question
    @question.destroy
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

  def question_cable(question_form, action)
    ActionCable.server.broadcast(
      'questions',
      { question: QuestionSerializer.new(question_form), action: action }.as_json
    )
  end
end
