# Generated via
#  `rails generate curation_concerns:work ObjectResource`

module CurationConcerns
  class ObjectResourcesController < ApplicationController
    include CurationConcerns::CurationConcernController
    # Adds Sufia behaviors to the controller.
    include Sufia::WorksControllerBehavior
    include LocalAuthorityHashConverter
    include MembersHelper

    self.curation_concern_type = ObjectResource

    # Display the form the the user.
    def new
      curation_concern.created_date_attributes = [{label: 'LABEL'}]
      super
    end

    def edit
      curation_concern.created_date_attributes = [{label: 'LABEL', note: ''}] if curation_concern.created_date.nil? || curation_concern.created_date.empty?
      super
    end

    def build_form
      attrs = curation_concern.attributes.dup
      attrs.each do |key, val|
        curation_concern.attributes[key] = hash_to_uri val
      end

      @form = form_class.new(curation_concern, current_ability)
    end
  end
end
