# Generated via
#  `rails generate curation_concerns:work ObjectResource`

module CurationConcerns
  class ObjectResourcesController < ApplicationController
    include CurationConcerns::CurationConcernController
    # Adds Sufia behaviors to the controller.
    include Sufia::WorksControllerBehavior

    self.curation_concern_type = ObjectResource
  end
end
