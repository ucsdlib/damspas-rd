class DownloadsController < ApplicationController
  include CurationConcerns::DownloadBehavior

  def authorize_download!
    authorize! :read, FileSet.find(params[asset_param_key])
  end
end
