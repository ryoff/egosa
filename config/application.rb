require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Egosa
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.helper false
      g.jbuilder false
      g.test_framework :rspec, routing_specs: false, request_specs: false, controller_specs: false, view_specs: false, helper_specs: false, fixture: false
      g.integration_tool false
    end
  end
end
