# Authority is super class that has possible subclasses
class Authority < ActiveFedora::Base
   extend ActiveTriples::Configurable
   include ActiveModel::Validations

  property :label, predicate: ::RDF::Vocab::SKOS.prefLabel, multiple: false
  property :alternate_label, predicate: ::RDF::Vocab::SKOS.altLabel, multiple: false
  # xsd:anyURI
  property :exact_match, predicate: ::RDF::Vocab::SKOS.exactMatch, multiple: true

  validates :label, presence: { message: 'Label is required.' }
  validates_with LabelExistsValidator
  validates :exact_match, url: true, allow_blank: true

  def self.is_authority?(record)
    record.is_a?(Authority) || record.class.ancestors.include?(Authority) || record.is_a?(UcsdAgent) || record.is_a?(Concept)
  end

  def to_solr(solr_doc = {})
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name('label', :stored_searchable)] = label
      solr_doc[Solrizer.solr_name('alternate_label', :stored_searchable)] = alternate_label if !alternate_label.blank?
      solr_doc['uri_ssim'] = uri
      index_authorities solr_doc, :exact_match, exact_match
    end
  end

  protected
    def index_authorities(solr_doc, field_name, authorities)
      authorities.each do |auth|
        index_authority_field solr_doc, field_name, auth
      end
    end

    def index_authority_field(solr_doc, field_name, field_value)
      solr_doc[Solrizer.solr_name(field_name, :stored_searchable)] = authority_label(field_value)
      solr_doc[Solrizer.solr_name(field_name, :symbol)] = field_value.to_s
    end

    def authority_label(obj)
      return if obj.nil? || obj.to_s.blank?
      return obj.label if Authority.is_authority? obj
      obj = obj.id if obj.is_a? ActiveTriples::Resource
      obj = begin
        ActiveFedora::Base.find(obj.split("/")[-1]).label
      rescue
      end if obj.to_s.start_with?(ActiveFedora.fedora.host) || obj.to_s.start_with?(Rails.configuration.authority_path)
      obj
    end
end
