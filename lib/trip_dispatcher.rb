require 'csv'
require 'time'

require_relative 'passenger'
require_relative 'trip'
require_relative 'driver'

module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips
    
    def initialize(directory: './support')
      @passengers = Passenger.load_all(directory: directory)
      @trips = Trip.load_all(directory: directory)
      @drivers = Driver.load_all(directory: directory)
      connect_trips
    end
    
    def find_passenger(id)
      Passenger.validate_id(id)
      return @passengers.find { |passenger| passenger.id == id }
    end
    
    def find_driver(id)
      Driver.validate_id(id)
      return @drivers.find { |driver| driver.id == id }
    end
    
    def inspect
      # Make puts output more useful
      return "#<#{self.class.name}:0x#{object_id.to_s(16)} \
      #{trips.count} trips, \
      #{drivers.count} drivers, \
      #{passengers.count} passengers>"
    end
    
    def request_trip(passenger_id)
      trip_driver = nil
      @drivers.find do |driver|
        if driver.status == :AVAILABLE
          trip_driver = driver
        end
      end
      if trip_driver == nil
        return "No available drivers at this time. Please try again later."
      end
      
      passenger = find_passenger(passenger_id)
      
      requested_trip = RideShare::Trip.new(
        id: trips.length + 1, 
        passenger: passenger, 
        start_time: Time.now, 
        cost: nil, 
        end_time: nil, 
        rating: nil, 
        driver: trip_driver
      )
      
      trip_driver.status = :UNAVAILABLE
      
      passenger.add_trip(requested_trip)
      trip_driver.add_trip(requested_trip)
      @trips << requested_trip
      
      return requested_trip
    end
    
    
    private
    
    def connect_trips
      @trips.each do |trip|
        passenger = find_passenger(trip.passenger_id)
        driver = find_driver(trip.driver_id)
        trip.connect(passenger, driver)
      end
      
      return trips
    end
  end
end
