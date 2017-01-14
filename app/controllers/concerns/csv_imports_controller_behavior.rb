  module CsvImportsControllerBehavior
    extend ActiveSupport::Concern
    include Hydra::Controller::ControllerBehavior
    include Hyrax::CurationConcernController

    included do
      self.work_form_service = CsvImportsFormService
      self.curation_concern_type = work_form_service.form_class.model_class
    end

    def create
      authenticate_user!
      create_update_job
      flash[:notice] = t('hyrax.works.new.after_create_html', application_name: view_context.application_name)
      redirect_after_update
    end

#    def create
#      authenticate_user!
#      create_update_job
#      flash[:notice] = t('csv_create', application_name: view_context.application_name)
#      redirect_after_update
#    end

    # Gives the class of the form.
    class CsvImportsFormService < Hyrax::WorkFormService
      def self.form_class(_ = nil)
        ::CsvImportForm
      end
    end

    protected

      def redirect_after_update
        if uploading_on_behalf_of?
          redirect_to hyrax.dashboard_shares_path
        else
          redirect_to hyrax.dashboard_works_path
        end
      end

      def create_update_job
        log = Hyrax::BatchCreateOperation.create!(user: current_user,
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
