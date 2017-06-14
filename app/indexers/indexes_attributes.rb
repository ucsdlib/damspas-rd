# frozen_string_literal: true

module IndexesAttributes
  extend ActiveSupport::Concern
  STORED_BOOL = Solrizer::Descriptor.new(:boolean, :stored, :indexed)

  # date: TimeSpan
  DATE = Solrizer.solr_name('date', :stored_searchable)
  CREATED_DATE = Solrizer.solr_name('created_date', :stored_searchable)
  EVENT_DATE = Solrizer.solr_name('event_date', :stored_searchable)
  COLLECTION_DATE = Solrizer.solr_name('collection_date', :stored_searchable)
  COPYRIGHT_DATE = Solrizer.solr_name('copyrighted_date', :stored_searchable)
  ISSUE_DATE = Solrizer.solr_name('issue_date', :stored_searchable)

  SORTABLE_DATE = Solrizer.solr_name('date', :sortable)

  AUTHORITIES_TERMS = [:creator, :contributor, :rights_holder, :publisher, :topic, :spatial].freeze

  def generate_solr_document
    super.tap do |doc|
      # Authorities
      index_authorities doc

      # dates
      index_dates doc

      # resource types
      index_resource_types doc

      # languages
      index_languages doc

      # related resource: RelatedResource
      index_related_resources doc

      # visibility: suppressed
      index_suppress_discovery doc
    end
  end

  private

    def index_authorities(solr_doc)
      AUTHORITIES_TERMS.each do |term|
        object[term].each do |au|
          val = authority_label au
          facet_searchable solr_doc, term.to_s, val
        end
      end
    end

    def index_dates(solr_doc)
      solr_doc[DATE] = display_date('date')
      solr_doc[CREATED_DATE] = created_date
      solr_doc[EVENT_DATE] = display_date('event_date')
      solr_doc[COLLECTION_DATE] = display_date('collection_date')
      solr_doc[COPYRIGHT_DATE] = display_date('copyrighted_date')
      solr_doc[ISSUE_DATE] = display_date('issue_date')
    end

    def index_resource_types(solr_doc)
      cv_list = MetadataService.find_all_resource_types
      object.resource_type.each do |uri|
        label = label_for_resource(cv_list, uri)
        facet_searchable solr_doc, 'resource_type', label
        solr_doc[Solrizer.solr_name('resource_type', :searchable)] = uri
      end
    end

    def index_languages(solr_doc)
      cv_list = MetadataService.find_all_languages
      object.language.each do |uri|
        label = label_for_resource(cv_list, uri)
        facet_searchable solr_doc, 'language', label
        solr_doc[Solrizer.solr_name('resource_type', :searchable)] = uri
      end
    end

    def index_related_resources(solr_doc)
      object.related_resource.each do |res|
        facet_searchable solr_doc, 'related_resource', res.display_label
        solr_doc[Solrizer.solr_name("related_resource_json", :stored_searchable)] = res.to_json
      end
    end

    def index_suppress_discovery(solr_doc)
      visibility_value = VisibilityService.visibility_value(object.rights_override) if object.rights_override
      return unless visibility_value == VisibilityService::VISIBILITY_TEXT_VALUE_SUPPRESS_DISCOVERY
      solr_doc[Solrizer.solr_name('suppress_discovery', STORED_BOOL)] = true
    end

    def facet_searchable(solr_doc, field_name, val)
      Solrizer.insert_field(solr_doc, field_name, val, :facetable)
      Solrizer.insert_field(solr_doc, field_name, val, :stored_searchable)
    end

    def display_date(date_name)
      Array(object[date_name]).map(&:display_label)
    end

    def created_date
      return if object.created_date.blank?
      object.created_date.first.display_label
    end

    def authority_label(obj)
      return if obj.nil? || obj.to_s.blank?
      if Authority.authority? obj
        obj.label
      elsif obj.start_with?(ActiveFedora.fedora.host)
        ActiveFedora::Base.find(obj.to_s.split("/")[-1]).label
      else
        obj.to_s
      end
    end

    def label_for_resource(cv_list, uri)
      Array(cv_list.find(proc { [uri] }) { |pair| pair[1] == uri }).first
    end
end
