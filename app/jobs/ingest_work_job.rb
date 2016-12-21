class IngestWorkJob < CreateWorkJob

  # This copies metadata from the passed in attribute to all of the works that
  # are members of the given upload set
  # @param [User] user
  # @param [String] model
  # @param [Hash] attributes
  # @param [BatchCreateOperation] log
  def perform(user, model, attributes, log)
    log.performing!
    attributes.each do |key, value|
      if value.is_a? Array
        value.map! { |v| to_hash(v) }
      else
        to_hash(value)
      end
    end

    work = model.constantize.new
    actor = work_actor(work, user)

    status = actor.create(attributes)

    return log.success! if status
    log.fail!(work.errors.full_messages.join(' '))
  end

  private

    def to_hash(val)
      begin
        val.start_with?(ActiveFedora.fedora.host) ? ActiveFedora::Base.find(ActiveFedora::Base.uri_to_id(val)).uri : val
      rescue
        val
      end
    end
end
