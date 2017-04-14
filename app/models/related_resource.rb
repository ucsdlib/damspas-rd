# Class for Related Resource, which is a super class that has possible subclasses
class RelatedResource < ActiveTriples::Resource
  include StoredInline
  include ActiveModel::Validations

  configure type: ::UcsdTerms.RelatedResource

  property :related_type, predicate: ::UcsdTerms::relatedType
  property :name, predicate: ::RDF::Vocab::SKOS.prefLabel
  property :url, predicate: ::RDF::Vocab::SCHEMA.url

  validates :related_type, presence: { message: 'Related resource must have a type.' }
  validates :url, url: true, allow_blank: true

  # Return a string for display of this record
  def display_label
    if name.present? && url.present?
      "#{related_type.first}: #{name.first} #{url.first}"
    elsif name.present?
      "#{related_type.first}: #{name.first}"
    else
      "#{related_type.first}: #{url.first}"
    end
  end
end
