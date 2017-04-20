# Generated via
#  `rails generate hyrax:work ObjectResource`
module Hyrax
  module Actors
    class ObjectResourceActor < Hyrax::Actors::BaseActor

      protected
        # override to clear the existing nested attribute that will be replaced.
        def apply_save_data_to_curation_concern(attributes)

          # remove existing attributes that are carried from nested attributes
          attributes.dup.each do |k, v|
            next unless (k.ends_with? '_attributes') && (!curation_concern.attributes[k.gsub('_attributes', '')].nil?)
            curation_concern.attributes[k.gsub('_attributes', '')].clear
          end
          attributes
          super
        end

        # If any attributes are blank remove them
        def remove_blank_attributes!(attributes)
          super
          attributes.each {|k, v| attributes[k] = nil if (!v.nil? && v.to_s.strip.blank?)}
        end
    end
  end
end
