# Generated via
#  `rails generate hyrax:work ObjectResource`
module Hyrax
  module Actors
    class ObjectResourceActor < Hyrax::Actors::BaseActor
      protected

        # override to clear the existing nested attribute that will be replaced.
        def apply_save_data_to_curation_concern(env)
          # remove existing attributes that are carried from nested attributes
          env.attributes.dup.each do |k, v|
            attributes = env.curation_concern.attributes
            next unless (k.to_s.ends_with? '_attributes') && !attributes[k.to_s.gsub('_attributes', '')].nil?
            attributes[k.to_s.gsub('_attributes', '')].clear
            env.attributes[k] = v.values if v.respond_to? 'key?'
          end
          super
        end

        # If any attributes are blank remove them
        def remove_blank_attributes!(attributes)
          super
          attributes.each { |k, v| attributes[k] = nil if !v.nil? && v.to_s.strip.blank? }
        end
    end
  end
end
