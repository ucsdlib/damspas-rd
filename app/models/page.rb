class Page < ActiveRecord::Base
  validates_format_of :slug, with: /\A([a-z0-9_])+\z/i
  validates :slug, presence: true, uniqueness: true
  validates :title, presence: true
end
