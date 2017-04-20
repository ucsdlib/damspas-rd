class TimeSpan < ActiveTriples::Resource
  include StoredInline

  configure type: ::RDF::Vocab::EDM.TimeSpan
  property :start, predicate: ::RDF::Vocab::EDM.begin
  property :finish, predicate: ::RDF::Vocab::EDM.end
  property :label, predicate: ::RDF::Vocab::SKOS.prefLabel

  # Return a string for display of this record
  def display_label
    if label.present?
      label.first
    elsif start.present? && finish.present? && start != finish
      [start.first, finish.first].compact.join(' to ')
    else
      start.present? ? start.first : finish.first
    end
  end
end
