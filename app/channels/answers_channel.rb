class AnswersChannel < ApplicationCable::Channel
  def subscribed
    stream_from "question/#{params[:question_id]}/answers"
  end
end
