module Sabre
  class Hotel
    attr_accessor :area_id, :name, :address, :phone, :fax, :location_description, :chain_code, :hotel_code, :latitude, :longitude, :rates, :rating, :amenities, :property_types, :description, :cancellation, :rooms_available, :services, :policies, :attractions

    def initialize(basic_info)
      @area_id = basic_info[:@area_id] 
      @name = basic_info[:@hotel_name].titleize
      if basic_info[:address][:tpa_extensions]
        @address = basic_info[:address][:tpa_extensions][:address_line].compact
      else
        @address = basic_info[:address][:address_line].compact
      end
      @phone = basic_info[:contact_numbers][:contact_number][:@phone]
      @fax = basic_info[:contact_numbers][:contact_number][:@fax]
      @chain_code = basic_info[:@chain_code]
      @hotel_code = basic_info[:@hotel_code]
      if basic_info[:position]
        @latitude = basic_info[:position][:@latitude]
        @longitude = basic_info[:position][:@longitude]
      else
        @latitude = basic_info[:@latitude]
        @longitude = basic_info[:@longitude]
      end
    end

    def self.find_by_geo(session, start_time, end_time, latitude, longitude, guest_count, amenities = [])
      raise SabreException::SearchError, 'No results found when missing latitude and longitude' if latitude.to_f == 0.0 || longitude.to_f == 0.0
      client = Sabre.client('OTA_HotelAvailLLS1.11.1RQ.wsdl')
      response = client.request(:ota_hotel_avail_rq, Sabre.request_header('2003A.TsabreXML1.11.1')) do
        Sabre.namespaces(soap)
        soap.header = session.header('Hotel Availability','sabreXML','OTA_HotelAvailLLSRQ')
        soap.body = {
          'POS' => Sabre.pos,
          'AvailRequestSegments' => {
            'AvailRequestSegment' => {
              'StayDateRange' => '', 
              'RatePlanCandidates' => {
                'RateRange' => '', :attributes! => { 'RateRange' => { 'CurrencyCode' => 'USD', 'Max' => '1000.00', 'Min' => '20.00' }}
              }, 'RoomStayCandidates' => room_stay_candidates(guest_count),
              'HotelSearchCriteria' => {
                 'Criterion' => { 
                   'HotelAmenity' => amenities.join(","), 'HotelRef' => '', 'RefPoint' => 'G', :attributes! => {
                     'HotelRef' => { 'Latitude' => latitude, 'Longitude' => longitude }, 
                   'HotelAmenity' => amenities.map(&:upcase), 'HotelRef' => '', 'RefPoint' => 'G', :attributes! => {
                     'RefPoint' => { 'GEOCodeOnly' => 'true', 'LocationCode' => 'R' },
                   } 
                 }
              }, :attributes! => { 
                'StayDateRange' => { 'Start' => start_time.strftime('%m-%d'), 'End' => end_time.strftime('%m-%d') }, 
                'RatePlanCandidates' => { 'SuppressRackRate' => 'false' },
                'HotelSearchCriteria' => { 'NumProperties' => 20 } 
              }
            }
          }
        }
      end
      construct_response_hash(response)
    end

    def self.find_by_iata(session, start_time, end_time, iata_city_code, guest_count, amenities = [])
      raise SabreException::SearchError, 'Missing IATA City Code - No search results found' if iata_city_code.nil?
      client = Sabre.client('OTA_HotelAvailLLS1.11.1RQ.wsdl')
      response = client.request(:ota_hotel_avail_rq, Sabre.request_header('2003A.TsabreXML1.11.1')) do
        Sabre.namespaces(soap)
        soap.header = session.header('Hotel Availability','sabreXML','OTA_HotelAvailLLSRQ')
        soap.body = {
          'POS' => Sabre.pos,
          'AvailRequestSegments' => {
  'AvailRequestSegment' => {
                'StayDateRange' => '', 
                'RoomStayCandidates' => room_stay_candidates(guest_count),
                'HotelSearchCriteria' => {
                  'Criterion' => { 
                    'HotelAmenity' => amenities.join(","), 'HotelRef' => '', :attributes! => {
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
      construct_response_hash(response)
    end

    def self.rate_details(session, hotel_id, visit_start, visit_end, guest_count, line_number)
    	client = Sabre.client('HotelRateDescriptionLLS1.9.1RQ.wsdl')
	    response = client.request(:hotel_rate_description_rq, Sabre.request_header('1.9.1')) do
        Sabre.namespaces(soap)
		    soap.header = session.header('Hotel Rates','sabreXML','HotelRateDescriptionLLSRQ')
		    soap.body = {
          'POS' => Sabre.pos,
				  'AvailRequestSegments' => {
					 	'AvailRequestSegment' => {
              'RatePlanCandidates' => { 'RatePlanCandidate' => '', :attributes! => { 'RatePlanCandidate' => { 'RPH' => line_number.to_s }} 
							}
				    }
			    }
	    	}
	    end
	    result = response.to_hash[:hotel_rate_description_rs]
	    raise SabreException::ConnectionError, Sabre.error_message(result) if result[:errors] 
	    return response
    end

    def self.profile(session,hotel_id, start_time, end_time, guest_count)
    	client = Sabre.client('HotelPropertyDescriptionLLS1.12.1RQ.wsdl')
	    response = client.request(:hotel_property_description_rq, Sabre.request_header('2003A.TsabreXML1.11.1')) do
        Sabre.namespaces(soap)
		    soap.header = session.header('Hotel Description','sabreXML','HotelPropertyDescriptionLLSRQ')
		    soap.body = {
          'POS' => Sabre.pos,
          'AvailRequestSegments' => {
              'AvailRequestSegment' => {
                  'StayDateRange' => '', :attributes! => { 'StayDateRange' => {
                      'Start' => start_time.strftime('%Y-%m-%d'), 'End' => end_time.strftime('%Y-%m-%d')
                  } }, 'RoomStayCandidates' => room_stay_candidates(guest_count),
                  'HotelSearchCriteria' => {
                        'Criterion' => { 'HotelRef' => '', :attributes! => {
                          'HotelRef' => { 'HotelCode' => hotel_id }
                        } }
                   }
              }
			    }
	    	}
	    end
	    result = response.to_hash[:hotel_property_description_rs]
	    raise SabreException::ConnectionError, Sabre.error_message(result) if result[:errors] 
	    return construct_full_response_hash(response)
    end

    private
    def self.construct_response_hash(results)
      hotels = []
      if results.to_hash[:ota_hotel_avail_rs][:errors].nil?

        results.to_hash[:ota_hotel_avail_rs][:availability_options][:availability_option].each do |p|
          prop_info = p[:basic_property_info]

          #street, city, state, postal_code = sanitize_address(
          #  prop_info[:address][:address_line].first.titleize,
          #  prop_info[:address][:address_line].last.split(' ')
          #)

          hotel = Hotel.new(prop_info)
          hotel.location_description = prop_info[:location_description][:text]

          rates = []
          if rate_range = prop_info[:rate_range]
            rates << {:description => 'Minimum', :amount => rate_range[:@min], :currency => rate_range[:@currency_code]}
            rates << {:description => 'Maximum', :amount => rate_range[:@max], :currency => rate_range[:@currency_code]}
          end

          hotel.rates = rates

          hotel.amenities = prop_info[:property_option_info].map do |key, val|
             key.to_s if val[:@ind] == 'true'
          end.compact.uniq
          
          rating = ''
          if prop_info[:property]
            hotel.rating = prop_info[:property][:text]
          end

          hotels << hotel 
        end
      else
        result = results.to_hash[:ota_hotel_avail_rs]
        raise SabreException::SearchError, Sabre.error_message(result) if result[:errors]
      end
      return hotels
    end

    def self.construct_full_response_hash(result)
      hotel = nil
      p = result.to_hash[:hotel_property_description_rs]
      if p[:errors].nil?
        room_stay = p[:room_stays][:room_stay]
        prop_info = room_stay[:basic_property_info]

        hotel = Hotel.new(prop_info)
        cards = []
        room_stay = p[:room_stays][:room_stay]
        if room_stay[:rate_plans]
          room_stay[:rate_plans][:rate_plan][:guarantee][:guarantees_accepted][:guarantee_accepted][:payment_card].each do |cc|
            cards << cc[:@card_type]
          end
        end

        rates = []
        line_number = nil
        if room_stay[:room_rates]
          if room_stay[:room_rates][:room_rate]
            room_stay[:room_rates][:room_rate].each do |rr|
              code = rr[:@rate_plan_code]
              line_number = rr[:@rph]
              if rr[:rates]
                tax, total = tax_rate(rr)

                rates << {
                  description: rate_description(rr),
                  code: code,
                  line_number: line_number,
                  amount: rr[:rates][:rate][:@amount],
                  currency: rr[:rates][:rate][:@currency_code],
                  taxes: tax,
                  total_pricing: total
                }
              end
            end
          elsif room_stay[:room_plans]
            room_stay[:room_plans][:room_plan].each do |rr|
              if rr[:rates]
                tax, total = tax_rate(rr)

                rates << {
                  description: rate_description(rr),
                  amount: rr[:rates][:rate][:@amount],
                  currency: rr[:rates][:rate][:@currency_code],
                  taxes: tax,
                  total_pricing: total
                }
              end
            end
          end
          hotel.rates = rates
        end # End building rates

        points_of_interest = []
        begin
          prop_info[:tpa_extensions][:index_data][:index].each do |poi|
            pt = poi[:@point]
            distance = poi[:@distance_direction].strip
          end
          points_of_interest << {:point => pt, :distance_direction => distance}
        rescue
        end
        #hotel.points_of_interest

        details = {}
        begin
          prop_info[:vendor_messages][:vendor_message].first.last.each do |msg|
            text = msg[:paragraph][:text]
            detail = {msg[:@sub_title].underscore.to_sym => text}
            details = details.merge!(detail)
          end
          hotel.description = details[:description].join(' ').split('. ').map{|sentence| sentence.capitalize}.join('. ')
          hotel.location_description = details[:location]
          hotel.rooms_available = details[:rooms]
          hotel.cancellation = details[:cancellation]
          hotel.services = details[:services]
          hotel.policies = details[:policies]
          hotel.attractions = details[:attractions]

        rescue
        end

        hotel.amenities = prop_info[:tpa_extensions][:property_option_info].map do |key, val|
          key.to_s.gsub('_', ' ').titleize if val[:@ind] == 'true'
        end.compact

        hotel.property_types = prop_info[:tpa_extensions][:property_type_info].map do |key, val|
          key.to_s.gsub('_', ' ').titleize if val[:@ind] == 'true'
        end.compact 
      else
        raise SabreException::SearchError, Sabre.error_message(p) if p[:errors]
      end
      return hotel
    end

    def self.rate_description(rate_result)
      description = rate_result[:tpa_extensions][:text]
      description = description.join(' ') if description.kind_of? Array
      description.gsub! /\s?[,|\/],?\s?/, ", "
      description = description.titleize
    end

    def self.tax_rate(room_rate)
      tax = nil
      total = nil
      if room_rate[:rates][:rate][:tpa_extensions]
        total = room_rate[:rates][:rate][:tpa_extensions][:hotel_total_pricing][:@amount]
        taxes = room_rate[:rates][:rate][:tpa_extensions][:hotel_total_pricing][:total_taxes]
        tax = taxes ? taxes[:@amount] : nil
      end
      return tax, total
    end

    def self.room_stay_candidates(number_of_guests)
      {
        'RoomStayCandidate' => { 
          'GuestCounts' => { 
            'GuestCount' => '', :attributes! => { 
              'GuestCount' => { 'Count' => number_of_guests } 
            } 
          } 
        } 
      }
    end    
  end
end
