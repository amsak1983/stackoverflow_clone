module ResourceHandling
  extend ActiveSupport::Concern
  include ErrorHandling
  
  included do
    before_action :set_resource, only: [:show, :edit, :update, :destroy]
    before_action :authorize_user!, only: [:edit, :update, :destroy]
    before_action :authenticate_user!, except: [:index, :show]
  end
  
  # Common actions
  def index
    collection_name = "@#{resource_name.pluralize}"
    resources = resource_class.send(scope_method || :all)
    instance_variable_set(collection_name, resources)
  end
  
  def show; end
  
  def new
    resource = resource_class.new
    instance_variable_set("@#{resource_name}", resource)
  end
  
  def edit; end
  
  def create
    resource = resource_class.new(resource_params)
    resource.user = current_user
    instance_variable_set("@#{resource_name}", resource)
    
    respond_to do |format|
      if resource.save
        handle_success(format, resource, "#{resource_name.humanize} was successfully created.")
      else
        handle_failure(format, resource, :new)
      end
    end
  end
  
  def update
    resource = instance_variable_get("@#{resource_name}")
    
    respond_to do |format|
      if resource.update(resource_params)
        handle_success(format, resource, "#{resource_name.humanize} was successfully updated.")
      else
        handle_failure(format, resource, :edit)
      end
    end
  end
  
  def destroy
    resource = instance_variable_get("@#{resource_name}")
    resource.destroy
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to send("#{resource_name.pluralize}_path"), notice: "#{resource_name.humanize} was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  
  private
  
  def handle_success(format, resource, notice)
    format.turbo_stream
    format.html { redirect_to resource, notice: notice }
    format.json { render :show, status: :ok, location: resource }
  end
  
  def handle_failure(format, resource, action)
    format.turbo_stream { render action, status: :unprocessable_entity }
    format.html { render action, status: :unprocessable_entity }
    format.json { render json: resource.errors, status: :unprocessable_entity }
  end
  
  # Methods to be implemented in including class
  def resource_class
    raise NotImplementedError, "#{self.class} must implement #{__method__}"
  end
  
  def resource_name
    resource_class.model_name.element
  end
  
  def resource_params
    params.require(resource_name.to_sym).permit(*permitted_params)
  end
  
  def permitted_params
    raise NotImplementedError, "#{self.class} must implement #{__method__}"
  end
  
  def scope_method
    nil # Can be overridden to provide a scope method (e.g., :recent, :popular)
  end
end
