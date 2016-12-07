class ApplicationController < ActionController::Base
  around_action :anonymous_user

  def anonymous_user
    # check ip for unauthenticated users
    if current_user.nil? && self.class != Qa::TermsController
      anon = User.anonymous(request.remote_ip)
      if anon.campus?
        @current_user = anon
        logger.warn "#{self.class.name}: wrapping request in anonymous user session (#{current_user})  from ip #{request.remote_ip} to_s: #{anon.to_s}"
      end
    end
    yield
  end

  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds CurationConcerns behaviors to the application controller.
  include CurationConcerns::ApplicationControllerBehavior  
  # Adds Sufia behaviors into the application controller 
  include Sufia::Controller

  include CurationConcerns::ThemedLayoutController
  with_themed_layout '1_column'


  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
