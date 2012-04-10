module Sabre
  class Reservation
    def self.book(session, chain_code, hotel_code, unit_count, guest_count, line_number, amount, currency, name, card_code, card_number, expire_date, start_date, end_date )
      client = Sabre.client('OTA_HotelResLLS1.4.1RQ.wsdl')
      response = client.request(:ota_hotel_res_rq, Sabre.request_header('1.4.1')) do
        Sabre.namespaces(soap)
        soap.header = session.header('Hotel Booking','sabreXML','OTA_HotelResLLSRQ')
        soap.body = {
          'POS' => Sabre.pos,
             'HotelReservations' => {
              'HotelReservation' => {
                'RoomStays' => { 
                  'RoomStay' => {
                    'RoomTypes' => {
                      'RoomType' => '', :attributes! => { 'RoomType' => { 'NumberOfUnits' => unit_count } } 
                    }, 
                    'BasicPropertyInfo' => { 'Line' => '', :attributes! => { 'Line' => { 'Number' => line_number } } }
                  }
                }, 
                'Profiles' => {
                  'Customer' => { 
                     'PaymentForm' => { 
                        'PaymentCard' => { 
                          'Guarantee' => {
                            'PersonName' => {
                              'Surname' => name
                            }
                          }, :attributes! => { 'Guarantee' => { 'Code' => 'G' } } 
                        }, :attributes! => { 'PaymentCard' => { 'CardCode' => card_code, 'CardNumber' => card_number, 'ExpireDate' => expire_date.strftime('%Y-%m') } } 
                     } 
                  }   
                }
              }
          }
      }
      end
      result = response.to_hash[:ota_hotel_res_rs]
      raise SabreException::ConnectionError, Sabre.error_message(result) if result[:errors]
      return response
    end

    def self.confirm(session, full_name)
      client = Sabre.client('EndTransactionLLS1.4.1RQ.wsdl')
      response = client.request(:end_transaction_rq, Sabre.request_header('1.4.1')) do
        Sabre.namespaces(soap)
        soap.header = session.header('Hotel Booking Confirmation','sabreXML','EndTransactionLLSRQ')
        soap.body = {
          'POS' => Sabre.pos,
          'UpdatedBy' => { 'TPA_Extensions' => { 'Access' => { 'AccessPerson' => { 'GivenName' => full_name } } } },
          'EndTransaction' => '', :attributes! => { 'EndTransaction' => { 'Ind' => 'true' } }
        }
      end
    end

    def self.cancel_stay(session,reservation_id = '1')
      client = Sabre.client('OTA_CancelLLSRQ.wsdl')
      response = client.request(:ota_cancel_rq, Sabre.request_header('1.0.1')) do
      Sabre.namespaces(soap)
      soap.header = session.header('Cancel Reservation','sabreXML','OTA_CancelLLSRQ')
      soap.body = {
          'POS' => Sabre.pos,
          'TPA_Extensions' => { 
            'SegmentCancel' => { 
              'Segment' => '', :attributes! => { 'Segment' => { 'Number' => reservation_id } } 
            }, :attributes! => {'SegmentCancel' => {'Type' => 'Hotel'}} 
          }
	    }
      end
    end
  end
end
