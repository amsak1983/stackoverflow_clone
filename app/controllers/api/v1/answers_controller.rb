module Api
  module V1
    class AnswersController < BaseController
      before_action :set_question, only: %i[index create]
      before_action :set_answer, only: %i[show update destroy]

      def index
        answers = policy_scope(@question.answers)
        render json: answers, each_serializer: AnswerSerializer
      end

      def show
        authorize @answer
        render json: @answer, serializer: AnswerSerializer
      end

      def create
        answer = @question.answers.build(answer_params.merge(user: current_user))
        authorize answer
        if answer.save
          render json: answer, serializer: AnswerSerializer, status: :created
        else
          render json: { errors: answer.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @answer
        if @answer.update(answer_params)
          render json: @answer, serializer: AnswerSerializer
        else
          render json: { errors: @answer.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @answer
        @answer.destroy
        head :no_content
      end

      private

      def set_question
        @question = Question.find(params[:question_id])
      end

      def set_answer
        @answer = Answer.find(params[:id])
      end

      def answer_params
        params.require(:answer).permit(:body)
      end
    end
  end
end
