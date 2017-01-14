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

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'


  protect_from_forgery with: :exception
  # disabling CSRF protection for the sign_in action to walk around error InvalidAuthenticityToken
  # in Devise::SessionsController#create
  skip_before_filter :verify_authenticity_token, if: -> { controller_name == 'sessions' && action_name == 'create' }
end

