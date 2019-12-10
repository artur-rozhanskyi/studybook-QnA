module Api
  module V1
    class QuestionsController < ApiController
      def index
        respond_with Question.all
      end

      def show
        respond_with Question.find(params[:id])
      end

      def create
        question = Question.create(question_params.merge(user: current_resource_owner))
        respond_with question
      end

      private

      def question_params
        params.require(:question).permit(:title, :body)
      end
    end
  end
end
