class ApplicationController < ActionController::Base
  around_action :anonymous_user
  helper_method :current_user

  def anonymous_user
    # check ip for unauthenticated users
    if current_user.nil? && self.class != Qa::TermsController
      anon = User.anonymous(request.remote_ip)
      @current_user = anon if anon.campus?
    end
    yield
  end

  def current_user
    @current_user ||= User.find_by uid: session[:user_id] if session[:user_id]
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
  skip_before_action :verify_authenticity_token, if: -> { controller_name == 'sessions' && action_name == 'create' }
end
