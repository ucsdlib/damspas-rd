# spec/support/features.rb
Dir[Rails.root.join('spec/support/features/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
  config.include Features::StubViewHelpers, type: :view
  config.include Features::InputHelper, type: :input
end
