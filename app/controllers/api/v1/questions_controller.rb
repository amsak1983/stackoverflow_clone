module Api
  module V1
    class QuestionsController < BaseController
      before_action :set_question, only: %i[show update destroy]

      def index
        questions = policy_scope(Question).recent
        render json: questions, each_serializer: QuestionSerializer
      end

      def show
        authorize @question
        render json: @question, serializer: QuestionSerializer
      end

      def create
        question = current_user.questions.build(question_params)
        authorize question
        if question.save
          render json: question, serializer: QuestionSerializer, status: :created
        else
          render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @question
        if @question.update(question_params)
          render json: @question, serializer: QuestionSerializer
        else
          render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @question
        @question.destroy
        head :no_content
      end

      private

      def set_question
        @question = Question.find(params[:id])
      end

      def question_params
        params.require(:question).permit(:title, :body)
      end
    end
  end
end
