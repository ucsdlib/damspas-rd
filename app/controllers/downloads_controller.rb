class DownloadsController < ApplicationController
  include DownloadBehavior

  def authorize_download!
    authorize! :read, FileSet.find(params[asset_param_key])
  end
end

