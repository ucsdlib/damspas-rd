module Hyrax
  module Dashboard
    module CollectionsControllerOverride
      include LocalAuthorityHashConverter
      include LocalAuthorityValueConverter
      def form_class
        ::CollectionEditForm
      end

      def presenter_class
        ::CollectionShowPresenter
      end

      private

        def collection_params
          attrs = form_class.model_attributes(params[:collection])
          # convert authority value to hash
          authority_hash attrs

          # permit the nested attributes and clear the existing attributes derived from nested resources.
          attrs.keys.each do |key|
            next unless key.ends_with? '_attributes'
            attrs[key].permit!
            if @collection && @collection.attributes[key.gsub('_attributes', '')]
              @collection.attributes[key.gsub('_attributes', '')].clear
            end
          end
          attrs
        end

        def form
          @collection.attributes.dup.each do |key, val|
            if key == 'language'
              language_service = LanguageSelectService.new
              val = val.collect { |v| language_service.get_label v }
              @collection.attributes[key].clear.push val
            else
              @collection.attributes[key] = hash_to_uri val
            end
          end
          @collection.created_date_attributes = [{ label: 'LABEL' }] if @collection.created_date.blank?
          # trick to initiate the form for nested resource
          if @collection.related_resource.blank?
            @collection.related_resource_attributes = [{ related_type: 'relation' }]
          end
          @form ||= form_class.new(@collection, current_ability, repository)
        end
    end
  end
end
