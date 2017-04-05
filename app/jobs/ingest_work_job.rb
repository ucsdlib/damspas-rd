class IngestWorkJob < CreateWorkJob

  # This copies metadata from the passed in attribute to all of the works that
  # are members of the given upload set
  # @param [User] user
  # @param [String] model
  # @param [Hash] attributes
  # @param [BatchCreateOperation] log
  def perform(user, model, components, log)
    levels = []
    works = []
    status = []
    log.performing!

    components.each do |attributes|
      levels << Import::TabularImporter.const_get(attributes.delete(:level).gsub('-', '').upcase)

      attributes.each do |key, value|
        if value.is_a? Array
          value.map! { |v| to_hash(v) }
        else
          to_hash(value)
        end
      end

      work = model.constantize.new
      works << work
      actor = work_actor(work, user)
      status << actor.create(attributes)
    end

    if components.count <= 1
      return log.fail!('No records ingested!') if components.count == 0
      return log.success! if status.first
      log.fail!(works.first.errors.full_messages.join(' '))
    else
      # construct components to complex object
      parent = works.first
      previous_level = levels.first
      levels.each_with_index do |level, index|
        next unless index > 0
        if level < previous_level

          # changing from sub-component to component, save the component with sub-components members
          begin
            parent.save
          rescue exception => e
            status[0] = false
            parent.errors.add(:base, :add_child_relationship_failed, message: e.to_s)
          end

          # parent changed to the object
          parent = works.first
        elsif level > previous_level
          # changing from component to sub-component, parent change form the object to the previous component
          parent = works[index - 1]
        end

        previous_level = level
        parent.ordered_members << works[index]

      end

      # save the object with the component member relationship
      begin
        parent.save
        works.first.save if parent != works.first
      rescue Exception => e
        parent.errors.add(:base, :add_child_relationship_failed, message: e.to_s)
        status[0] = false
      end

      # report the ingest status
      return log.fail!(works.select {|work| work.errors.full_messages.join(' ') if work.errors.count > 0}) if status.select { |s| s == false }.count > 0
      log.success!
    end
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
