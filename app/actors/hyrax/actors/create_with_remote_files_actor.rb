module Hyrax
  module Actors
    # Attaches remote files to the work
    class CreateWithRemoteFilesActor < Hyrax::Actors::AbstractActor
      ORIGINAL_FILE = ExtendedContainedFiles::ORIGINAL_FILE

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if create was successful
      def create(env)
        remote_files = env.attributes.delete(:remote_files)
        file_uses = file_use(env.attributes)
        next_actor.create(env) && attach_files(env, remote_files, file_uses)
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if update was successful
      def update(env)
        remote_files = env.attributes.delete(:remote_files)
        file_uses = file_use(env.attributes)
        next_actor.update(env) && attach_files(env, remote_files, file_uses)
      end

      private

        # @param [HashWithIndifferentAccess] remote_files
        # @return [TrueClass]
        def attach_files(env, remote_files, file_uses)
          return true unless remote_files

          ingest_remote_files(env, remote_files, file_uses)

          true
        end

        # Generic utility for creating FileSet from a URL
        # Used in to import files using URLs from a file picker like browse_everything
        def create_file_from_url(env, file_infos, file_uses)
          fs = create_file_set(env)
          file_infos.each_with_index do |file_info, index|
            fs.update(import_url: file_info[:url].to_s, label: file_info[:file_name])
            uri = URI.parse(URI.encode(file_info[:url]))
            if uri.scheme == 'file'
              IngestLocalFileJob.perform_later(fs, URI.decode(uri.path), env.user, file_uses[index])
            else
              ImportUrlWithFileUseJob.perform_later(fs, operation_for(user: env.user), uri, file_uses[index])
            end
          end
        end

        def operation_for(user:)
          Hyrax::Operation.create!(user: user,
                                   operation_type: "Attach Remote File")
        end

        # File use for fileset
        def file_use(attributes)
          return [] unless attributes.key? :file_use
          attributes[:file_use]
        end

        def create_file_set(env)
          work_permissions = env.curation_concern.permissions.map(&:to_hash)
          ::FileSet.new do |fs|
            actor = Hyrax::Actors::FileSetActor.new(fs, env.user)
            actor.create_metadata(visibility: env.curation_concern.visibility)
            actor.attach_to_work(env.curation_concern)
            fs.permissions_attributes = work_permissions
            fs.save!
          end
        end

        # Arrange and attach the remote files basing on file use provided
        # @param [Hyrax::Actors::Environment] env
        # @param [Array] remote_files
        # @param [Array] file_uses
        def ingest_remote_files(env, remote_files, file_uses)
          file_set_urls = []
          file_set_file_uses = []
          remote_files.each_with_index do |file_info, index|
            next if file_info.blank? || file_info[:url].blank?

            file_use = file_uses.present? && file_uses.count > index ? file_uses[index] : ORIGINAL_FILE
            attach_remote_files_to_file_set(env, file_set_urls, file_set_file_uses) if file_use == ORIGINAL_FILE
            file_set_file_uses << file_use
            file_set_urls << file_info
          end

          # Files in the last file set that need attached
          attach_remote_files_to_file_set(env, file_set_urls, file_set_file_uses)
        end

        # Attach files with file uses to a FileSet
        # @param [Array] file_set_urls
        # @param [Array] file_set_file_uses
        def attach_remote_files_to_file_set(env, file_set_urls, file_set_file_uses)
          # One original_file one FileSet: multiple files with different file uses will be attached to a FileSet
          return unless file_set_urls.count.positive?
          create_file_from_url(env, file_set_urls.select { |f| f }, file_set_file_uses.select { |u| u })
          file_set_urls.clear
          file_set_file_uses.clear
        end
    end
  end
end
