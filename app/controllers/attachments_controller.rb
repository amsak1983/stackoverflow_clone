class AttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_attachment
  before_action :check_author

  # DELETE /attachments/:id
  def destroy
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

  def check_author
    return if current_user&.author_of?(@record)

    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, alert: "You do not have permission to delete this file") }
      format.json { head :forbidden }
      format.turbo_stream { head :forbidden }
    end
    head :forbidden and return
  end
end
