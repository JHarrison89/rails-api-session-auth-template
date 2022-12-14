# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'example.com'

    # this wildcard makes CORs open to requests from all websites > ‘*’

    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: true # required for cookies to work
  end
end

Rails.application.config.action_controller.forgery_protection_origin_check = false
