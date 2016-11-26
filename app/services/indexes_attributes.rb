module IndexesAttributes extend ActiveSupport::Concern
  # date: TimeSpan
  DATE = Solrizer.solr_name('date', :stored_searchable)
  CREATED_DATE = Solrizer.solr_name('created_date', :stored_searchable)
  EVENT_DATE = Solrizer.solr_name('event_date', :stored_searchable)
  COLLECTION_DATE = Solrizer.solr_name('collection_date', :stored_searchable)
  COPYRIGHT_DATE = Solrizer.solr_name('date_copyrighted', :stored_searchable)
  ISSUE_DATE = Solrizer.solr_name('issue_date', :stored_searchable)

  SORTABLE_DATE = Solrizer.solr_name('date', :sortable)

  AUTHORITIES_TERMS = [:creator, :contributor, :publisher, :topic, :spatial]
  def generate_solr_document
    super.tap do |solr_doc|

      # Authorities
      AUTHORITIES_TERMS.each do |term|
        object[term].each do |au|
          val = authority_label au
          facet_searchable solr_doc, term.to_s, val
        end
      end

      solr_doc[DATE] = display_date('date')
      solr_doc[CREATED_DATE] = created_date
      solr_doc[EVENT_DATE] = display_date('event_date')
      solr_doc[COLLECTION_DATE] = display_date('collection_date')
      solr_doc[COPYRIGHT_DATE] = display_date('copyright_date')
      solr_doc[ISSUE_DATE] = display_date('issue_date')

      # facet field in general schema
      cv_list = MetadataService.find_all_resource_types
      object.resource_type.each do |uri|
        label = label_for_resource(cv_list, uri)
        facet_searchable solr_doc, 'resource_type', label
        solr_doc[Solrizer.solr_name('resource_type', :searchable)] = uri
      end

      cv_list = MetadataService.find_all_languages
      object.language.each do |uri|
        label = label_for_resource(cv_list, uri)
        facet_searchable solr_doc, 'language', label
        solr_doc[Solrizer.solr_name('resource_type', :searchable)] = uri
      end
    end
  end

  private

    def facet_searchable (solr_doc, field_name, val)
      Solrizer.insert_field(solr_doc, field_name, val, :facetable)
      Solrizer.insert_field(solr_doc, field_name, val, :stored_searchable)
    end

    def display_date(date_name)
      Array(object[date_name]).map(&:display_label)
    end

    def created_date
      return unless object.created_date.present?
      object.created_date.first.display_label
    end

    def authority_label(obj)
      return if obj.nil? || obj.to_s.blank?
      if Authority.is_authority? obj
        obj.label
      elsif obj.start_with?(ActiveFedora.fedora.host)
        ActiveFedora::Base.find(obj.split("/")[-1]).label
      else
        obj.to_s
      end
    end

    def label_for_resource(cv_list, uri)
      Array(cv_list.find( proc { [uri] } ) { |pair| pair[1] == uri }).first
    end
end
