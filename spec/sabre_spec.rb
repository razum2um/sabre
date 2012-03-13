require 'spec_helper'

describe Sabre do
  context "Identifies request services" do
    let(:client) do
      Savon::Client.new do
        #wsdl.namespace = 'http://wsdl-crt.cert.sabre.com/'
        #wsdl.document = 'http://wsdl-crt.cert.sabre.com/sabreXML1.0.00/tpf/OTA_HotelAvailLLS1.11.1RQ.wsdl'
        wsdl.document = 'http://webservices.sabre.com/wsdl/sabreXML1.0.00/usg/SessionCreateRQ.wsdl'
      end
    end

    it "expects the client to return soap_actions" do
      client.wsdl.soap_actions.should == [:session_create_rq]
    end

  end

  context "Send SOAP Requests to Sabre" do
    before(:each) do 
      Sabre.cert_wsdl_url = 'http://wsdl-crt.cert.sabre.com/sabreXML1.0.00/usg/SessionCreateRQ.wsdl'
      Sabre.wsdl_url = 'http://wsdl-crt.cert.sabre.com/sabreXML1.0.00/tpf/'
      Sabre.ipcc = 'P40G'
      Sabre.account_email = 'joe@example.com'
      Sabre.domain = 'example.com'
      Sabre.username = '7971'
      Sabre.password = 'WS020212'
      @session = Sabre::Session.new
      @session.open
    end
 
    #it "should open a session" do
    #  FakeWeb.register_uri(:any,'http://wsdl-crt.cert.sabre.com/sabreXML1.0.00/usg/SessionCreateRQ.wsdl', :body => File.read('spec/fixtures/session_create_rq/success.xml'))
    #  @session.expects(:open).returns(:success) 
    #end

    it "should create a travel itinerary" do
      response = Sabre::Traveler.profile(@session, Faker::Name.first_name, Faker::Name.last_name, '303-861-9300')  
      response.to_hash.should include(:travel_itinerary_add_info_rs)
    end

    it "should return a list of hotels given a valid availability request" do
      Sabre::Hotel.find_by_geo(@session, (Time.now+172800), (Time.now+432000),'39.75','-104.87','1').to_hash.should include(:ota_hotel_avail_rs)
    end

    it "should return a list of hotels given a valid availability request" do
      Sabre::Hotel.find_by_iata(@session,Time.now+172800, Time.now+432000,'DFW','1').to_hash.should include(:ota_hotel_avail_rs)
    end

    # Works with 0040713 
    it "should return a hotels description response" do
      Sabre::Hotel.profile(@session,'0031653',Time.now+172800, Time.now+432000, '1').to_hash.should include(:hotel_property_description_rs)
    end

    # This needs to be a Long booking
    it "should book a hotel reservation" do
      Sabre::Reservation.book(@session,'ES','0040713','1','1','001','229.00','USD','TEST','AX','1234567890123245',(Time.now + 6000000),Time.now+172800, Time.now+432000).to_hash.should include(:ota_hotel_res_rs)
    end
 
    it "should cancel a hotel reservation" do
      #@sabre.cancel
    end

    after(:each) do
      @session.close
    end
  end
end
