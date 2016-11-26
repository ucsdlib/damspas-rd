# accepts_nested_attributes_for can not be called until all the properties are declared
# because it calls resource_class, which finalizes the propery declarations
# See https://github.com/projecthydra/active_fedora/issues/847
module NestedAttributes
  extend ActiveSupport::Concern

  included do
    id_blank = proc { |attributes| attributes[:id].blank? }

    # edm:Agent
    accepts_nested_attributes_for :creator, reject_if: proc { |attributes| attributes[:id].blank? }, allow_destroy: true
    accepts_nested_attributes_for :contributor, reject_if: proc { |attributes| attributes[:id].blank? }, allow_destroy: true

    # skos:Concept
    accepts_nested_attributes_for :topic, reject_if: proc { |attributes| attributes[:id].blank? }, allow_destroy: true

    # edm:Place
    accepts_nested_attributes_for :spatial, reject_if: :edm_place_blank, allow_destroy: true

    # temporal: edm:TimeSpan
    accepts_nested_attributes_for :temporal, reject_if: :time_span_blank, allow_destroy: true
    # rightsOverrideExpiration: edm:TimeSpan
    accepts_nested_attributes_for :rightsOverrideExpiration, reject_if: :time_span_blank, allow_destroy: true
    # dates
    accepts_nested_attributes_for :date, reject_if: :time_span_blank, allow_destroy: true
    accepts_nested_attributes_for :created_date, reject_if: :time_span_blank, allow_destroy: true
    accepts_nested_attributes_for :event_date, reject_if: :time_span_blank, allow_destroy: true
    accepts_nested_attributes_for :collection_date, reject_if: :time_span_blank, allow_destroy: true
    accepts_nested_attributes_for :copyright_date, reject_if: :time_span_blank, allow_destroy: true
    accepts_nested_attributes_for :issue_date, reject_if: :time_span_blank, allow_destroy: true

    resource_class.send(:define_method, :agent_blank) do |attributes|
      agent_attributes.all? do |key|
        Array(attributes[key]).all?(&:blank?)
      end
    end

    resource_class.send(:define_method, :agent_attributes) do
      [:label, :alternate_label, :identifier]
    end

    resource_class.send(:define_method, :edm_place_blank) do |attributes|
      edm_place_attributes.all? do |key|
        Array(attributes[key]).all?(&:blank?)
      end
    end

    resource_class.send(:define_method, :edm_place_attributes) do
      [:label]
    end

    resource_class.send(:define_method, :time_span_blank) do |attributes|
      time_span_attributes.all? do |key|
        Array(attributes[key]).all?(&:blank?)
      end
    end

    resource_class.send(:define_method, :time_span_attributes) do
      [:start, :start_qualifier, :finish, :finish_qualifier, :label, :note]
    end
  end
end
