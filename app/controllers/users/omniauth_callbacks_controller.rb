class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [:developer, :anonymous]
  def developer
    find_or_create_user('developer')
  end

  def shibboleth
    find_or_create_user('shibboleth')
  end

  def find_or_create_user(auth_type)
    find_or_create_method = "find_or_create_for_#{auth_type.downcase}".to_sym
    # logger.debug "#{auth_type} :: #{current_user.inspect}"
    @user = User.send(find_or_create_method, request.env["omniauth.auth"], current_user)
    current_uid = request.env['omniauth.auth'].uid
    if Rails.configuration.shibboleth && !User.in_admin_group?(current_uid) && !User.in_curator_group?(current_uid)
      render file: Rails.root.join('public', '403'), formats: [:html], status: 403, layout: false
    else
      create_user_session(@user) if @user
      if @user.persisted?
        flash[:success] = I18n.t "devise.omniauth_callbacks.success", kind: auth_type.capitalize
        sign_in @user, event: :authentication
      else
        session["devise.#{auth_type.downcase}_data"] = request.env["omniauth.auth"]
      end
      redirect_to request.env['omniauth.origin'] || root_url
    end
  end

  def create_user_session(user)
    session[:user_name] = user.name
    session[:user_id] = user.uid
  end
  protected :find_or_create_user
end
