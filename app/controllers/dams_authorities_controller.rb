class DamsAuthoritiesController < ApplicationController
  include LocalAuthorityHashAccessor

  def show
    path = Rails.application.routes.recognize_path(request.env['PATH_INFO'])
    authority_type = path[:authority]

    if ["agent", "concept", "place", "resourcetype"].include?(authority_type)
      @obj = ActiveFedora::Base.find(params[:id])

      @obj.attributes.dup.map { |key, value|
        if (value.is_a? ActiveTriples::Relation) || (value.is_a? Array) 
          values = Marshal.load(Marshal.dump(value))
          @obj.attributes[key].clear
          values.each { |v|
            v = v.id if v.respond_to?(:id)
            @obj.attributes[key] << to_hash(v)
          }
        end
      }
    else
      redirect_to "/"
    end

  end
end
