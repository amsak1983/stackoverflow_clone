class LinksController < ApplicationController
  include ErrorHandling
  before_action :authenticate_user!
  before_action :set_link, only: [ :destroy ]
  before_action :check_author, only: [ :destroy ]

  # DELETE /links/:id
  def destroy
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

  def check_author
    return if current_user&.author_of?(@link.linkable)

    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, alert: "You do not have permission to delete this link") }
      format.turbo_stream { head :forbidden }
    end
    head :forbidden and return
  end
end
