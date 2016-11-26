class TimeSpan < ActiveTriples::Resource
  include StoredInline

  configure type: ::RDF::Vocab::EDM.TimeSpan
  property :start, predicate: ::RDF::Vocab::EDM.begin
  property :finish, predicate: ::RDF::Vocab::EDM.end
  property :start_qualifier, predicate: ::RDF::Vocab::CRM.P79_beginning_is_qualified_by
  property :finish_qualifier, predicate: ::RDF::Vocab::CRM.P80_end_is_qualified_by
  property :label, predicate: ::RDF::Vocab::SKOS.prefLabel
  property :note, predicate: ::RDF::Vocab::SKOS.note

  # MODS date qualifiers
  APPROX = 'approximate'.freeze
  INFERRED = 'inferred'.freeze
  QUESTIONABLE = 'questionable'.freeze

  QUALIFIERS = [APPROX, INFERRED, QUESTIONABLE].freeze

  def self.qualifiers
    QUALIFIERS
  end

  def range?
    start.any?(&:present?) && finish.any?(&:present?)
  end

  # def node?
  #  false
  # end

  # Return a string for display of this record
  def display_label
    if label.present?
      label.first
    else
      start_string = qualified_date(start, start_qualifier)
      finish_string = qualified_date(finish, finish_qualifier)
      [start_string, finish_string].compact.join(' - ')
    end
  end

  def qualified_date(date, qualifier)
    if qualifier.include?(APPROX) || qualifier.include?(QUESTIONABLE)
      "ca. #{date.first}"
    else
      date.first
    end
  end

  # Return an array of years, for faceting in Solr.
  def to_a
    if range?
      (start_integer..finish_integer).to_a
    else
      start_integer
    end
  end

  def earliest_year
    start.reject(&:blank?).sort { |a, b| extract_year(a) <=> extract_year(b) }.first
  end

  private

    def start_integer
      extract_year(start.first)
    end

    def finish_integer
      extract_year(finish.first)
    end

    def extract_year(date)
      extract_year(date)
    end

    def extract_year(date)
      date = date.to_s
      if date.blank?
        nil
      elsif /^\d{4}$/ =~ date
        # Date.iso8601 doesn't support YYYY dates
        date.to_i
      else
        Date.iso8601(date).year
      end
    rescue ArgumentError
      raise "Invalid date: #{date.inspect} in #{inspect}"
    end
end
