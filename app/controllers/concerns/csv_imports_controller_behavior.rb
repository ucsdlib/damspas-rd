  module CsvImportsControllerBehavior
    extend ActiveSupport::Concern
    include Hydra::Controller::ControllerBehavior
    include CurationConcerns::CurationConcernController

    included do
      self.curation_concern_type = form_class.model_class
    end

    def create
      authenticate_user!
      create_update_job
      flash[:notice] = t('csv_create', application_name: view_context.application_name)
      redirect_after_update
    end

    module ClassMethods
      def form_class
        ::CsvImportForm
      end
    end

    protected

      # Gives the class of the form.
      # This overrides CurationConcerns
      def form_class
        self.class.form_class
      end

      def redirect_after_update
        if uploading_on_behalf_of?
          redirect_to sufia.dashboard_shares_path
        else
          redirect_to sufia.dashboard_works_path
        end
      end

      def create_update_job
        log = Sufia::BatchCreateOperation.create!(user: current_user,
                                           operation_type: "CSV Import")

        uploaded_files = params.fetch(:uploaded_files, [])
        selected_files = params.fetch(:selected_files, {}).values
        browse_everything_urls = uploaded_files &
                                 selected_files.map { |f| f[:url] }

        # we need the hash of files with url and file_name
        browse_everything_files = selected_files
                                  .select { |v| uploaded_files.include?(v[:url]) }

        CsvImportJob.perform_later(current_user,
                                     params[:csv_source].read,
                                     uploaded_files - browse_everything_urls,
                                     browse_everything_files,
                                     attributes_for_actor.to_h,
                                     log)
      end

      def uploading_on_behalf_of?
        params.fetch(hash_key_for_curation_concern).key?(:on_behalf_of)
      end
  end
