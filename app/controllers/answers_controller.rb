class AnswersController < ApplicationController
  before_action :set_answer, only: [:update, :destroy]

  def create
    @question = Question.find(params[:question_id])
    @answer = @question.answers.create(answer_params.merge(user: current_user))
  end

  def update
    @question = @answer.question
    @answer.update(answer_params) if current_user == @answer.user
  end

  def destroy
    @answer.destroy if current_user == @answer.user
  end

  private

  def set_answer
    @answer = Answer.find(params[:id])
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
