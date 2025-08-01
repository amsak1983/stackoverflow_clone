class LinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_link
  before_action :check_author

  def destroy
    @link.destroy
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  private

  def set_link
    @link = Link.find(params[:id])
  end

  def check_author
    unless current_user.author_of?(@link.linkable)
      respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.html { redirect_to root_path, alert: 'Вы не можете удалить эту ссылку' }
      end
    end
  end
end
