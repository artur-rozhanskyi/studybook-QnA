class AnswersController < ApplicationController
  before_action :set_question, only: :create
  before_action :set_answer, only: [:update, :destroy]

  def create
    @answer = @question.answers.build(answer_params.merge(user: current_user))
    if @answer.save
      answer_cable @answer, 'create'
      render body: nil
    else
      render json: @answer.error_messages, status: :unprocessable_entity
    end
  end

  def update
    @question = @answer.question
    @answer.update(answer_params) if current_user == @answer.user
    if @answer.errors.empty?
      answer_cable @answer, 'update'
      render body: nil
    else
      render json: @answer.error_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @answer.destroy if current_user == @answer.user
    answer_cable @answer, 'destroy' if @answer.destroyed?
    render body: nil
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
