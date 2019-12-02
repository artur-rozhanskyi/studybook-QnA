class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question, only: :create
  before_action :set_answer, only: [:update, :destroy]

  respond_to :json, :js

  def create
    answer_form = AnswerForm.new
    if answer_form.submit(answer_params.merge(user: current_user, question: @question))
      answer_cable answer_form, 'create'
    end
    respond_with answer_form
  end

  def update
    answer_form = AnswerForm.new @answer
    answer_cable answer_form, 'update' if answer_form.submit(answer_params.merge(user: current_user))
    respond_with answer_form
  end

  def destroy
    @answer.destroy if current_user == @answer.user
    answer_cable @answer, 'destroy' if @answer.destroyed?
    respond_with @answer
  end

  def show; end

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
      "question/#{answer.question_id}/answers",
      { answer: AnswerSerializer.new(answer), action: action }.as_json
    )
  end
end
