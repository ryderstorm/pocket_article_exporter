# frozen_string_literal: true

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

require 'simplecov'
SimpleCov.start

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus

  config.disable_monkey_patching!

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.order = :random

  Kernel.srand config.seed

  config.before(:each) do
    # Set up environment variables for testing
    ENV['POCKET_CONSUMER_KEY'] = 'test-consumer-key'
    ENV['POCKET_REDIRECT_URI'] = 'http://localhost:3000/auth/pocket/callback'
  end
end
