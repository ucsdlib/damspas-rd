module LocalAuthorityHashConverter
  extend ActiveSupport::Concern

  # Convert local authority hash
  def hash_to_uri(arg)
    return arg unless (arg.is_a? ActiveTriples::Relation) || (arg.is_a? Array) && !arg.empty?
    values = [].push(*arg)
    arg.clear
    convert_values values, arg
  end

  def convert_values(values, arg)
    values.map do |x|
      arg << if Authority.authority? x
               x.uri.to_s
             elsif (x.is_a? ActiveTriples::Resource) && !(x.is_a?(TimeSpan) || x.is_a?(RelatedResource))
               x.id
             else
               x
             end
    end
  end
end
