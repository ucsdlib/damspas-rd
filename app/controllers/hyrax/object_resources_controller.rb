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
      # trick to trigger the form for nested attributes
      curation_concern.related_resource_attributes = [{name: 'LABEL'}]
      super
    end

    def edit
      curation_concern.created_date_attributes = [{label: 'LABEL'}] if curation_concern.created_date.nil? || curation_concern.created_date.empty?
      # trick to trigger the form for nested attributes
      curation_concern.related_resource_attributes = [{name: 'LABEL'}] if curation_concern.related_resource.nil? || curation_concern.related_resource.empty?
      super
    end

    def build_form
      attrs = curation_concern.attributes.dup
      attrs.each do |key, val|
        if key == 'language'
          language_service = LanguageSelectService.new
          val = val.collect { |v| language_service.get_label v }
          curation_concern.attributes[key].clear.push val
        else
          curation_concern.attributes[key] = hash_to_uri val
        end
      end

      @form = work_form_service.build(curation_concern, current_ability, self)
    end

    def search_builder_class
      ::WorkSearchBuilder
    end

    def show_presenter
      ::ObjectShowPresenter
    end

    def add_breadcrumb_relation
      if action_name == 'edit' || action_name == 'show'
        @document = ::SolrDocument.find(params[:id])
        if !@document[:member_of_collections_ssim].blank?
          collection_name = @document[:member_of_collections_ssim].first
          collection_id = @document[:member_of_collection_ids_ssim].first
          add_breadcrumb collection_name, hyrax.collection_path(collection_id)
        end
      end
    end

    def build_breadcrumbs
      if action_name == 'show'
        default_trail
      else
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      end
        add_breadcrumb_relation
        add_breadcrumb_for_action
    end
  end
end
