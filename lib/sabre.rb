require 'sabre/version'
require 'yaml'
require 'savon'
require 'sabre/session'
require 'sabre/traveler'
require 'sabre/hotel'
require 'sabre/reservation'

module Sabre
  def self.config
    YAML.load(File.read(File.expand_path('../../config/sabre.yml', __FILE__)))
	end

	def self.client(service)
    Savon::Client.new(config['development']['wsdl_url']+service)
	end
end
