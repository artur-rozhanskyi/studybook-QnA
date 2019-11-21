class AnswersController < ApplicationController
  before_action :set_question, only: :create
  before_action :set_answer, only: [:update, :destroy]

  respond_to :json, :js

  def create
    @answer = @question.answers.create(answer_params.merge(user: current_user))
    answer_cable @answer, 'create' if @answer.valid?
    respond_with @answer
  end

  def update
    @question = @answer.question
    @answer.update(answer_params) if current_user == @answer.user
    answer_cable @answer, 'update' if @answer.valid?
    respond_with @answer
  end

  def destroy
    @answer.destroy if current_user == @answer.user
    answer_cable @answer, 'destroy' if @answer.destroyed?
    respond_with @answer
  end

  private

  def set_answer
    @answer = Answer.find(params[:id])
  end

  def set_question
    @question = Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:body, attachments_attributes: [:file, :remove_file, :id, :_destroy])
  end

  def answer_cable(answer, action)
    ActionCable.server.broadcast(
      "question/#{answer.question.id}/answers",
      { answer: AnswerSerializer.new(answer), action: action }.as_json
    )
  end
end
