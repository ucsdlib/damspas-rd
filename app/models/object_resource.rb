# Generated via
#  `rails generate hyrax:work ObjectResource`
class ObjectResource < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  include ::CommonMetadata
  include NestedAttributes

  self.human_readable_type = 'Object'
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :language, url: {message: 'Invalid label for language field!'}, allow_blank:true

  def self.indexer
    ::WorkIndexer
  end
end
