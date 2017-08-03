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
      levels << Import::TabularImporter.const_get(attributes.delete(:level).delete('-').upcase)
      work = model.constantize.new
      works << work
      current_ability = Ability.new(user)
      env = Hyrax::Actors::Environment.new(work, current_ability, attributes)
      status << work_actor.create(env)
    end

    if components.count <= 1
      return log.fail!('No records ingested!') if components.count.zero?
      return log.success! if status.first
      log.fail!(works.first.errors.full_messages.join(' '))
    else
      # construct components to complex object
      parent = works.first
      previous_level = levels.first
      levels.each_with_index do |level, index|
        next unless index.positive?
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

      # set default thumbnail for the complex object
      assign_thumbnail works

      # save the object with the component member relationship
      begin
        parent.save
        works.first.save if parent != works.first
      rescue StandardError => e
        parent.errors.add(:base, :add_child_relationship_failed, message: e.to_s)
        status[0] = false
      end

      # report the ingest status
      if status.select { |s| s == false }.count.positive?
        return log.fail!(works.select { |work| work.errors.full_messages.join(' ') if work.errors.count.positive? })
      end
      log.success!
    end
  end

  private

    # set complex object thumbnail if not set yet.
    # @params [ObjectResource] works
    def assign_thumbnail(works)
      return unless works.count > 1 && works.first.thumbnail.nil?
      work = works.detect { |w| !w.thumbnail.nil? }
      works.first.thumbnail = work.thumbnail if work
    end
end
