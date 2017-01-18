# Generated via
#  `rails generate hyrax:work ObjectResource`

module Hyrax
  class ObjectResourcesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks

    include LocalAuthorityHashConverter
    include MembersHelper

    helper Rails.application.routes.url_helpers

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

      @form = work_form_service.build(curation_concern, current_ability, self)
    end

    def search_builder_class
      ::WorkSearchBuilder
    end

    def show_presenter
      ::ObjectShowPresenter
    end
  end
end
