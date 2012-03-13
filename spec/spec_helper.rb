#$LOAD_PATH.unshift(File.dirname(__FILE__))
#$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
#$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib/generators/templates'))
#require 'rspec'
#require 'yaml'
require 'ruby-debug'
require 'mocha'
require 'fakeweb'
require 'ffaker'
require 'savon'
require 'savon_spec'
require 'sabre'

RSpec.configure do |config|
  config.mock_with :mocha
  config.include Savon::Spec::Macros

  Savon::Spec::Fixture.path = File.expand_path("../fixtures", __FILE__) 
#  config.before :each do 
    # Make sure we don't ever send requests
#    HTTPI.expects(:get).never
#    HTTPI.expects(:post).never
#  end
end
