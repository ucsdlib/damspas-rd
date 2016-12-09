class CollectionsController < ApplicationController
  include CurationConcerns::CollectionsControllerBehavior
  include Sufia::CollectionsControllerBehavior
  include LocalAuthorityHashConverter

  def form
    attrs = @collection.attributes.dup
    attrs.each do |key, val|
      @collection.attributes[key] = hash_to_uri val
    end

    @form ||= form_class.new(@collection)
  end

  def form_class
    CollectionEditForm
  end

  def presenter_class
    CollectionShowPresenter
  end

  def single_item_search_builder
    ::WorkSearchBuilder.new(self).with(params.except(:q, :page))
  end

  def list_search_builder
    ::CurationConcerns::CollectionSearchBuilder.new(self)
  end
end
