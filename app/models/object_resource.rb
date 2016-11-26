# Generated via
#  `rails generate curation_concerns:work ObjectResource`
class ObjectResource < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include Sufia::WorkBehavior

  include ::CommonMetadata
  include NestedAttributes

  self.human_readable_type = 'Object'
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
end
