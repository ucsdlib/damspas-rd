module Hyrax
  class CollectionsController < ApplicationController
    include Hyrax::CollectionsControllerBehavior
    include Hyrax::BreadcrumbsForCollections
    layout :decide_layout
    load_and_authorize_resource except: [:index, :show, :create], instance_name: :collection

    include LocalAuthorityHashConverter
    include LocalAuthorityValueConverter

    # The search builder to find the collection
    self.single_item_search_builder_class = ::SingleCollectionSearchBuilder
    # The search builder to find the collections' members
    self.member_search_builder_class = ::CollectionMemberSearchBuilder

    def form
      @collection.attributes.dup.each do |key, val|
        if key == 'language'
          language_service = LanguageSelectService.new
          val = val.collect { |v| language_service.get_label v }
          @collection.attributes[key].clear.push val
        else
          @collection.attributes[key] = hash_to_uri val
        end
      end

      @collection.created_date_attributes = [{ label: 'LABEL' }] if @collection.created_date.blank?
      # trick to initiate the form for nested resource
      if @collection.related_resource.blank?
        @collection.related_resource_attributes = [{ related_type: 'relation' }]
      end

      @form ||= form_class.new(@collection, current_ability, repository)
    end

    def collection_params
      attrs = super

      # convert authority value to hash
      authority_hash attrs

      # permit the nested attributes and clear the existing attributes derived from nested resources.
      attrs.keys.each do |key|
        next unless key.ends_with? '_attributes'
        attrs[key].permit!
        if @collection && @collection.attributes[key.gsub('_attributes', '')]
          @collection.attributes[key.gsub('_attributes', '')].clear
        end
      end
      attrs
    end

    def presenter_class
      ::CollectionShowPresenter
    end

    def form_class
      ::CollectionEditForm
    end

    # If any attributes are blank remove them
    def remove_blank_attributes!(attributes)
      super
      attributes.each { |k, v| attributes[k] = nil if !v.nil? && v.to_s.strip.blank? }
    end

    # Renders a JSON response with a list of files in this collection
    # This is used by the edit form to populate the thumbnail_id dropdown
    def files
      result = form.select_files.map do |label, id|
        { id: id, text: label }
      end
      render json: result
    end

    private

      def decide_layout
        case action_name
        when 'show'
          theme
        else
          'dashboard'
        end
      end
  end
end
