require 'sabre/version'
require 'yaml'
require 'savon'
require 'sabre/session'
require 'sabre/traveler'
require 'sabre/hotel'
require 'sabre/reservation'

module Sabre
  mattr_accessor :cert_wsdl_url, :wsdl_url, :endpoint_url, :username, :password, :ipcc, :binary_security_token, :ref_message_id

	def self.client(service)
    Savon::Client.new(self.wsdl_url+service)
	end

  def self.setup
    yield self
  end
	
end
