module Sabre
  class Hotel
    def self.find_by_geo(session, start_time, end_time, latitude, longitude, guest_count, amenities = [])
      client = Sabre.client('OTA_HotelAvailLLS1.11.1RQ.wsdl')
      client.http.headers["Content-Type"] = "text/xml;charset=UTF-8"
      response = client.request(:ota_hotel_avail_rq, { 'xmlns' => 'http://webservices.sabre.com/sabreXML/2003/07', 'xmlns:xs' => 'http://www.w3.org/2001/XMLSchema', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'TimeStamp' => Time.now.strftime('%Y-%m-%dT%H:%M:%S'), 'Version' => '2003A.TsabreXML1.11.1'}) do
        soap.namespaces["xmlns:SOAP-ENV"] = "http://schemas.xmlsoap.org/soap/envelope/"
	soap.namespaces["xmlns:eb"] = "http://www.ebxml.org/namespaces/messageHeader"
	soap.namespaces["xmlns:xlinx"] = "http://www.w3.org/1999/xlink"
	#soap.namespaces["xmlns"] = 'http://www.opentravel.org/OTA/2002/08'
	soap.version = 1
	soap.header = session.header('Hotel Availability','sabreXML','OTA_HotelAvailLLSRQ')
	soap.body = {
          'POS' => { 'Source' => "", :attributes! => { 'Source' => { 'PseudoCityCode' => session.ipcc } } },
	     'AvailRequestSegments' => {
		'AvailRequestSegment' => {
                    'StayDateRange' => '', 'RoomStayCandidates' => {
                    'RoomStayCandidate' => { 'GuestCounts' => { 'GuestCount' => '', :attributes! => { 'GuestCount' => { 'Count' => guest_count } } } } 
                    }, 'HotelSearchCriteria' => {
			'Criterion' => { 
                           amenities.each do |amenity|
                             'HotelAmenity' => amenity
                           end
                            'HotelRef' => '', 'RefPoint' => 'G', :attributes! => {
                                'HotelRef' => { 'Latitude' => latitude, 'Longitude' => longitude }, 
														'RefPoint' => { 'GEOCodeOnly' => 'true', 'LocationCode' => 'R' }
													} }
										 }, :attributes! => { 
												'StayDateRange' => { 'Start' => start_time.strftime('%m-%d'), 'End' => end_time.strftime('%m-%d') }, 
												'HotelSearchCriteria' => { 'NumProperties' => 20 } 
		       }
		 }
	     }
	}
    end
  end

		def self.find_by_iata(session, start_time, end_time, iata_city_code, guest_count, amenities = [])
			client = Sabre.client('OTA_HotelAvailLLS1.11.1RQ.wsdl')
			client.http.headers["Content-Type"] = "text/xml;charset=UTF-8"
			response = client.request(:ota_hotel_avail_rq, { 'xmlns' => 'http://webservices.sabre.com/sabreXML/2003/07', 'xmlns:xs' => 'http://www.w3.org/2001/XMLSchema', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'TimeStamp' => Time.now.strftime('%Y-%m-%dT%H:%M:%S'), 'Version' => '2003A.TsabreXML1.11.1'}) do
				soap.namespaces["xmlns:SOAP-ENV"] = "http://schemas.xmlsoap.org/soap/envelope/"
				soap.namespaces["xmlns:eb"] = "http://www.ebxml.org/namespaces/messageHeader"
				soap.namespaces["xmlns:xlinx"] = "http://www.w3.org/1999/xlink"
				#soap.namespaces["xmlns"] = 'http://www.opentravel.org/OTA/2002/08'
				soap.version = 1
				soap.header = session.header('Hotel Availability','sabreXML','OTA_HotelAvailLLSRQ')
				soap.body = {
					'POS' => { 'Source' => "", :attributes! => { 'Source' => { 'PseudoCityCode' => session.ipcc } } },
						'AvailRequestSegments' => {
								'AvailRequestSegment' => {
										'StayDateRange' => '', 
										'RoomStayCandidates' => {
										 'RoomStayCandidate' => { 'GuestCounts' => { 'GuestCount' => '', :attributes! => { 'GuestCount' => { 'Count' => guest_count } } } } 
			}, 'HotelSearchCriteria' => {
												'Criterion' => { 'HotelRef' => '', :attributes! => {
														'HotelRef' => { 'HotelCityCode' => iata_city_code } 
													} }
										 }, :attributes! => { 
												'HotelSearchCriteria' => { 'NumProperties' => 20 }, 
												'StayDateRange' => { 'Start' => start_time.strftime('%m-%dT%H:%M:%S'), 'End' => end_time.strftime('%m-%dT%H:%M:%S') }  
										}
								}
						}
				 }
			end
		end

		def self.profile(session,hotel_id, start_time, end_time, guest_count)
			client = Sabre.client('HotelPropertyDescriptionLLS1.12.1RQ.wsdl')
			client.http.headers["Content-Type"] = "text/xml;charset=UTF-8"
			response = client.request(:hotel_property_description_rq, { 'xmlns' => 'http://webservices.sabre.com/sabreXML/2003/07', 'xmlns:xs' => 'http://www.w3.org/2001/XMLSchema', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'TimeStamp' => Time.now.strftime('%Y-%m-%dT%H:%M:%S'), 'Version' => '2003A.TsabreXML1.11.1'}) do
				soap.namespaces["xmlns:SOAP-ENV"] = "http://schemas.xmlsoap.org/soap/envelope/"
				soap.namespaces["xmlns:eb"] = "http://www.ebxml.org/namespaces/messageHeader"
				soap.namespaces["xmlns:xlinx"] = "http://www.w3.org/1999/xlink"
				soap.version = 1
				soap.header = session.header('Hotel Description','sabreXML','HotelPropertyDescriptionLLSRQ')
				soap.body = {
					'POS' => { 'Source' => "", :attributes! => { 'Source' => { 'PseudoCityCode' => session.ipcc } } },
						'AvailRequestSegments' => {
								'AvailRequestSegment' => {
										'StayDateRange' => '', :attributes! => { 'StayDateRange' => {
												'Start' => start_time.strftime('%Y-%m-%d'), 'End' => end_time.strftime('%Y-%m-%d')
										} }, 'RoomStayCandidates' => {
										 'RoomStayCandidate' => { 'GuestCounts' => { 'GuestCount' => '', :attributes! => { 'GuestCount' => { 'Count' => guest_count } } } } 
				}, 'HotelSearchCriteria' => {
													'Criterion' => { 'HotelRef' => '', :attributes! => {
														'HotelRef' => { 'HotelCode' => hotel_id }
													} }
										 }
								}
						}
				}
			end
			result = response.to_hash[:hotel_property_description_rs]
			raise SabreException::ConnectionError, error_message(result) if result[:errors] 
			return response
		end
  end
end
