module Api
  module V1
    class QuestionsController < ApiController
      skip_before_action :doorkeeper_authorize!, except: :create
      before_action :set_question, only: [:update, :destroy]

      def index
        respond_with Question.all
      end

      def show
        respond_with Question.find(params[:id])
      end

      def create
        @question_form = QuestionForm.new
        authorize @question_form
        question_cable @question_form, 'create' if @question_form.submit(question_params.merge(user: current_resource_owner))
        respond_with @question_form
      end

      def update
        @question_form = QuestionForm.new(@question)
        authorize @question_form
        question_cable @question_form, 'update' if @question_form.submit(question_params.merge(user: current_resource_owner))
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
  end
end
