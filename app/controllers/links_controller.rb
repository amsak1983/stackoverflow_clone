class LinksController < ApplicationController
  include ErrorHandling
  before_action :authenticate_user!
  before_action :set_link, only: [ :destroy ]
  after_action :verify_authorized

  # DELETE /links/:id
  def destroy
    authorize @link
    @link.destroy
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.turbo_stream
    end
  end

  private

  def set_link
    @link = Link.find_by(id: params[:id])
    handle_record_not_found("Link") unless @link
  end
end
