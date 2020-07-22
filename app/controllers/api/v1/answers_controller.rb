module Api
  module V1
    class AnswersController < ApiController
      before_action :set_question, only: [:create, :index]
      before_action :set_answer, only: [:show, :update, :destroy]

      def index
        respond_with @question.answers
      end

      def show
        respond_with @answer
      end

      def create
        answer_form = AnswerForm.new
        answer_cable answer_form, 'create' if answer_form.submit(answer_params.merge(user: current_resource_owner, question: @question))
        respond_with answer_form
      end

      def update
        answer_form = AnswerForm.new @answer
        authorize answer_form
        answer_cable answer_form, 'update' if answer_form.submit(answer_params.merge(user: current_resource_owner))
        respond_with answer_form
      end

      def destroy
        authorize @answer
        @answer.destroy
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
        params.require(:answer).permit(:body)
      end

      def answer_cable(answer, action)
        ActionCable.server.broadcast(
          "question/#{answer.question_id}/answers",
          { answer: AnswerSerializer.new(answer), action: action }.as_json
        )
      end
    end
  end
end
