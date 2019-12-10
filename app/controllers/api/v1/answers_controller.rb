module Api
  module V1
    class AnswersController < ApiController
      before_action :set_question, only: [:create, :index]

      def index
        respond_with @question.answers
      end

      def show
        respond_with Answer.find(params[:id])
      end

      def create
        answer = Answer.create(answer_params.merge(user: current_resource_owner, question: @question))
        respond_with answer
      end

      private

      def set_question
        @question = Question.find(params[:question_id])
      end

      def answer_params
        params.require(:answer).permit(:body)
      end
    end
  end
end
