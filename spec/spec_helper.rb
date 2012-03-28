#$LOAD_PATH.unshift(File.dirname(__FILE__))
#$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
#$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib/generators/templates'))
#require 'rspec'
#require 'yaml'
require 'ruby-debug'
require 'mocha'
require 'vcr'
require 'webmock/rspec'
require 'ffaker'
require 'savon'
require 'savon_spec'
require 'sabre'

HTTPI.log = false
#Savon.log = false

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes' 
  c.hook_into :webmock
  c.filter_sensitive_data('<IPCC>') { "P40G" }
  c.filter_sensitive_data('<USERNAME>') { "7971" }
  c.filter_sensitive_data('<PASSWORD>') { "WS020212" }
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].split(/\s+/,2).join("/").underscore.gsub(/[^\w\/]+/, "_")
    options = example.metadata.slice(:record, :match_requests_on).except(:example_group)
    VCR.use_cassette(name, options) { example.call }
  end
  config.mock_with :mocha
  config.include Savon::Spec::Macros

  Savon::Spec::Fixture.path = File.expand_path("../fixtures", __FILE__) 
#  config.before :each do 
    # Make sure we don't ever send requests
#    HTTPI.expects(:get).never
#    HTTPI.expects(:post).never
#  end
end
