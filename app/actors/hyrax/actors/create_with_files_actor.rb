module Hyrax
  module Actors
    # Creates a work and attaches files to the work
    class CreateWithFilesActor < Hyrax::Actors::AbstractActor
      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if create was successful
      def create(env)
        uploaded_file_ids = filter_file_ids(env.attributes.delete(:uploaded_files))
        files = uploaded_files(uploaded_file_ids)
        file_uses = file_use(env.attributes)
        validate_files(files, env) && next_actor.create(env) && attach_files(files, env, file_uses)
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if update was successful
      def update(env)
        uploaded_file_ids = filter_file_ids(env.attributes.delete(:uploaded_files))
        files = uploaded_files(uploaded_file_ids)
        file_uses = file_use(env.attributes)
        validate_files(files, env) && next_actor.update(env) && attach_files(files, env, file_uses)
      end

      private

        def filter_file_ids(input)
          Array.wrap(input).select(&:present?)
        end

        # ensure that the files we are given are owned by the depositor of the work
        def validate_files(files, env)
          expected_user_id = env.user.id
          files.each do |file|
            if file.user_id != expected_user_id
              Rails.logger.error "User #{env.user.user_key} attempted to ingest file #{file.id} belongs to other users"
              return false
            end
          end
          true
        end

        # @return [TrueClass]
        def attach_files(files, env, file_uses)
          return true unless files
          AttachFilesToFileSetJob.perform_later(env.curation_concern,
                                                files, file_uses, env.attributes.to_h.symbolize_keys)
          true
        end

        # Fetch uploaded_files from the database
        def uploaded_files(uploaded_file_ids)
          return [] if uploaded_file_ids.empty?
          UploadedFile.find(uploaded_file_ids)
        end

        # File use for fileset
        def file_use(attributes)
          return [] unless attributes.key? :file_use
          attributes.delete(:file_use)
        end
    end
  end
end
