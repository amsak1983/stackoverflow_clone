class AttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_attachment
  after_action :verify_authorized

  # DELETE /attachments/:id
  def destroy
    authorize @attachment
    @attachment.purge

    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.turbo_stream { render turbo_stream: turbo_stream.remove("attachment_#{params[:id]}") }
    end
  end

  private

  def find_attachment
    @attachment = ActiveStorage::Attachment.find(params[:id])
    @record = @attachment.record
  end
end
