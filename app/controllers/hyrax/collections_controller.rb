module Hyrax
  class CollectionsController < ApplicationController
    include Hyrax::CollectionsControllerBehavior
    include Hyrax::BreadcrumbsForCollections

    include LocalAuthorityHashConverter

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

      @form ||= form_class.new(@collection)
    end

    def collection_params
      attrs = super

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
  end
end
