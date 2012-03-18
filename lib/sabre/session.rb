require 'yaml'
require 'savon'

module Sabre
  class Session
    attr_accessor :username, :password, :ipcc, :binary_security_token, :ref_message_id, :account_email, :domain
    def initialize
      @username = Sabre.username
      @password = Sabre.password
      @ipcc = Sabre.ipcc
      @account_email = Sabre.account_email
      @domain = Sabre.domain

      #@client = Savon::Client.new(config[Rails.env]['wsdl_url'])
    end

    def open
      client = Savon::Client.new(Sabre.cert_wsdl_url)
      response = client.request(:session_create_rq) do
        soap.namespaces["xmlns:SOAP-ENV"] = "http://schemas.xmlsoap.org/soap/envelope/"
        soap.namespaces["xmlns:eb"] = "http://www.ebxml.org/namespaces/messageHeader"
        soap.namespaces["xmlns:xlinx"] = "http://www.w3.org/1999/xlink"
        soap.header = header('Session','sabreXML','SessionCreateRQ')      
        soap.body = { 'POS' => { 'Source' => "", :attributes! => { 'Source' => { 'PseudoCityCode' => self.ipcc } } } }
      end
      #doc = response.body
      @binary_security_token = response.xpath("//wsse:BinarySecurityToken")[0].content
      @ref_message_id = response.xpath("//eb:RefToMessageId")[0].content
    end


    def close
      client = Savon::Client.new(Sabre.cert_wsdl_url)
      client.request(:session_close_rq) do
        soap.namespaces["xmlns:SOAP-ENV"] = "http://schemas.xmlsoap.org/soap/envelope/"
        soap.namespaces["xmlns:eb"] = "http://www.ebxml.org/namespaces/messageHeader"
        soap.namespaces["xmlns:xlinx"] = "http://www.w3.org/1999/xlink"
        soap.header = header('Session','sabreXML','SessionCloseRQ')      
        soap.body = { 'POS' => { 'Source' => "", :attributes! => { 'Source' => { 'PseudoCityCode' => self.ipcc } } } }
      end
    end

    def header(service, type, action)
      msg_header = { 'eb:ConversationId' => self.account_email,
                  'eb:From' => { 'eb:PartyId' => self.domain, :attributes! => { 'eb:PartyId' => { 'type' => 'urn:x12.org:IO5:01' } } },
                  'eb:To' => { 'eb:PartyId' => "webservices.sabre.com", :attributes! => { 'eb:PartyId' => { 'type' => 'urn:x12.org:IO5:01' } } },
                  'eb:CPAId' => self.ipcc,
                  'eb:Service' => service, :attributes! => { 'eb:Service' => { 'eb:type' => type } },
                  'eb:Action' => action,
                  'eb:MessageData' => {
                     'eb:MessageId' => "mid:#{Time.now.strftime('%Y%m%d-%H%M%S')}@#{self.domain}",
                     'eb:RefToMessageId' => self.ref_message_id,
                     'eb:Timestamp' => Time.now.strftime('%Y-%m-%dT%H:%M:%SZ')
                  } }
      { 'eb:MessageHeader' => msg_header.to_hash, 
        'wsse:Security' => security.to_hash, :attributes! => { 'wsse:Security' => { 'xmlns:wsse' => "http://schemas.xmlsoap.org/ws/2002/12/secext" }, 'eb:MessageHeader' => { 'SOAP-ENV:mustUnderstand' => "1", 'eb:version' => "2.0" } } 
      }
    end

    def security
      if self.binary_security_token
        { 'wsse:BinarySecurityToken' => self.binary_security_token, :attributes! => { 'wsse:BinarySecurityToken' => { 'xmlns:wsu' => "http://schemas.xmlsoap.org/ws/2002/12/utility", 'wsu:Id' => 'SabreSecurityToken', 'valueType' => 'String', 'EncodingType' => "wsse:Base64Binary" } } }
      else 
        { 'wsse:UsernameToken' => { 'wsse:Username' => self.username, 'wsse:Password' => self.password, 'Organization' => self.ipcc, 'Domain' => 'DEFAULT' } }
      end
    end

    private
    def error_message(msg)
     "#{msg[:errors][:error][:@error_code]}: #{msg[:errors][:error][:@error_message]}: #{msg[:errors][:error][:error_info][:message]}" 
  	end
  end
end
