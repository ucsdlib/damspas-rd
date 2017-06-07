class Page < ActiveRecord::Base
  validates :slug, format: { with: /\A([a-z0-9_])+\z/i }
  validates :slug, presence: true, uniqueness: true
  validates :title, presence: true
end
