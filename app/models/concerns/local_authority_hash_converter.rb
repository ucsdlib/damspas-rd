module LocalAuthorityHashConverter
  extend ActiveSupport::Concern

  # Convert local authority hash
  def hash_to_uri(arg)
    if (arg.is_a? ActiveTriples::Relation) || (arg.is_a? Array) && !arg.empty?
      values = Marshal.load(Marshal.dump(arg))
      arg.clear
      values.map { |x|
        if Authority.is_authority? x
          arg << x.uri.to_s
        elsif (x.is_a? ActiveTriples::Resource) && !(x.is_a? TimeSpan)
          arg << x.id
        else
          arg << x
        end
      }
    end
    arg
  end
end
