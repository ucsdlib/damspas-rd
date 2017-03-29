class AuthorityAttributeRenderer < ::Hyrax::Renderers::AttributeRenderer
  def li_value(value)
    link_to(ERB::Util.h(value.to_s), options[:uri][value])
  end
end
