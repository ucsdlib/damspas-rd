# Extends and customizes the RecordsController in hydra-editor
class RecordsController < ApplicationController
  include RecordsControllerBehavior
  include LocalAuthorityHashConverter

  def index
    redirect_to "/"
  end

  def show
    resource = ActiveFedora::Base.find(params[:id])
    if resource.nil?
      flash[:error] = "Resource doesn't exist: #{params[:id]}"
      redirect_to "/"
    else
      redirect_to "/dams_authorities/#{resource.class.name.underscore}/#{params[:id]}"
    end
  end

  def deny_access(exception)
    redirect_to({ controller: :catalog, action: 'index' }, alert: "Error: #{exception.message}")
  end

  def build_form
    resource.attributes.each do |_key, value|
      hash_to_uri value
    end
    form_class.new(resource)
  end

  protected

    def redirect_after_create
      redirect_after_update
    end

    def redirect_after_update
      "/dams_authorities/#{resource.class.name.underscore}/#{resource.id}"
    end
end
