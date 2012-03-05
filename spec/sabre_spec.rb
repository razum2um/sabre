require 'spec_helper'

describe Sabre do
  before(:each) do 
    Sabre.cert_wsdl_url = 'http://wsdl-crt.cert.sabre.com/sabreXML1.0.00/usg/SessionCreateRQ.wsdl'
    Sabre.wsdl_url = 'http://wsdl-crt.cert.sabre.com/sabreXML1.0.00/tpf/'
    Sabre.ipcc = ''
    Sabre.username = ''
    Sabre.password = ''
    @session = Sabre::Session.new
    Sabre::Session.expects(:open).returns(true)
    @session.open
  end

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
