module Hyrax
  class DashboardController < ApplicationController
    include Blacklight::Base
    layout 'dashboard'
    before_action :authenticate_user!

    def show
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      if can? :read, :admin_dashboard
        @presenter = Hyrax::Admin::DashboardPresenter.new
        # use the local customize AdminSetSearchBuilder to fix the errors caused by the advance search builders
        @admin_set_rows = Hyrax::AdminSetService.new(self, ::AdminSetSearchBuilder).search_results_with_work_count(:read)
        render 'show_admin'
      else
        @presenter = Dashboard::UserPresenter.new(current_user, view_context, params[:since])
        render 'show_user'
      end
    end
  end
end
