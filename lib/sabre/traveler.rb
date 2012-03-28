module Sabre
  module Traveler
    def self.profile(session,first_name,last_name,phone)
      client = Sabre.client('TravelItineraryAddInfoLLS1.10.1RQ.wsdl')
      response = client.request(:travel_itinerary_add_info_rq, { 'xmlns' => 'http://webservices.sabre.com/sabreXML/2003/07', 'xmlns:xs' => 'http://www.w3.org/2001/XMLSchema', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'TimeStamp' => Time.now.strftime('%Y-%m-%dT%H:%M:%S'), 'Version' => '1.10.1'}) do
        Sabre.namespaces(soap)
        soap.header = session.header('Travel Itinerary Info','sabreXML','TravelItineraryAddInfoLLSRQ')
        soap.body = {
          'POS' => Sabre.pos,
          'AgencyInfo' => { 'Address' => { 
                  'AddressLine' => 'MyTravelersHaven.com',
                  'StreetNmbr' => '425 S. Cherry Street',
                  'CityName' => 'DENVER',
                  'PostalCode' => '80246',
                  'StateCountyProv' => '', 
                  'CountryCode' => 'US',
                  :attributes! => { 'StateCountyProv' => { 'StateCode' => 'CO' } }
              }, 
              'Ticketing' => '',
              :attributes! => { 'Ticketing' => { 'TicketType' => '7T-' } }
          },
          'CustomerInfo' => { 'PersonName' => { 'GivenName' => first_name, 'Surname' => last_name }, 'Telephone' => '', :attributes! => {
              'PersonName' => { 'TravelerRefNumber' => '1.1', 'NameReference' => 'REF1' }, 'Telephone' => { 'AreaCityCode' => '', 'PhoneNumber' => phone, 'PhoneUseType' => 'H', 'TravelerRefNumber' => '1.1' }
          }}
        }
      end
    end
    
    def self.locate(session, transaction_code)
      client = Sabre.client('TravelItineraryReadLLS1.1.1RQ.wsdl')
      response = client.request(:travel_itinerary_add_info_rq, { 'xmlns' => 'http://webservices.sabre.com/sabreXML/2003/07', 'xmlns:xs' => 'http://www.w3.org/2001/XMLSchema', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'TimeStamp' => Time.now.strftime('%Y-%m-%dT%H:%M:%S'), 'Version' => '1.1.1'}) do
	soap.namespaces["xmlns:SOAP-ENV"] = "http://schemas.xmlsoap.org/soap/envelope/"
	soap.namespaces["xmlns:eb"] = "http://www.ebxml.org/namespaces/messageHeader"
	soap.namespaces["xmlns:xlinx"] = "http://www.w3.org/1999/xlink"
	#soap.namespaces["xmlns"] = 'http://www.opentravel.org/OTA/2002/08'
	soap.version = 1 # Unable to internalize message if version 2 
	soap.header = session.header('Travel Itinerary Info','sabreXML','TravelItineraryReadLLSRQ')
	soap.body = {
			'POS' => Sabre.pos,
      'MessagingDetails' => { 'Transaction' => '', :attributes! => { 'Transaction' => { 'Code' => transaction_code } } },
          'UniqueID' => '', :attributes! => { 'UniqueID' => { 'ID' => reservation_id } } 
      } 
      end
    end
  end
end
