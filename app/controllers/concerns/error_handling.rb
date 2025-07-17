module ErrorHandling
  extend ActiveSupport::Concern

  private

  def handle_record_not_found(model_name)
    respond_to do |format|
      format.html { redirect_to questions_path, alert: "#{model_name} not found" }
      format.json { render json: { error: "#{model_name} not found" }, status: :not_found }
    end
  end
end
