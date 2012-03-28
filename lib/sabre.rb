require 'active_support/all'
require 'sabre/version'
require 'yaml'
require 'savon'
require 'sabre/session'
require 'sabre/traveler'
require 'sabre/hotel'
require 'sabre/reservation'
require 'sabre/sabre_exception'

module Sabre
  mattr_accessor :cert_wsdl_url, :wsdl_url, :endpoint_url, :username, :password, :ipcc, :account_email, :domain, :binary_security_token, :ref_message_id

  def self.client(service)
    client = Savon::Client.new(self.wsdl_url+service)
    client.http.headers["Content-Type"] = "text/xml;charset=UTF-8"
    return client
  end

  def self.setup
    yield self
  end

  def self.pos
    { 'Source' => "", :attributes! => { 'Source' => { 'PseudoCityCode' => self.ipcc } } }
  end

  def self.namespaces(soap)
    soap.namespaces["xmlns:SOAP-ENV"] = "http://schemas.xmlsoap.org/soap/envelope/"
    soap.namespaces["xmlns:eb"] = "http://www.ebxml.org/namespaces/messageHeader"
    soap.namespaces["xmlns:xlinx"] = "http://www.w3.org/1999/xlink"
    soap.version = 1
    return soap
  end
	
end
