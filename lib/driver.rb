require_relative 'csv_record'

module RideShare
  class Driver < CsvRecord
    attr_reader :name, :vin, :trips
    attr_accessor :status
    
    def initialize(id:, name:, vin:, status: "AVAILABLE", trips: nil)
      super(id)
      
      @name = name
      @vin = vin
      @status = status.to_sym
      @trips = trips || []
      
      
      if vin.length != 17
        raise ArgumentError.new("VIN must be 17 characters long.")
      end
      
      if status != "AVAILABLE" && status != "UNAVAILABLE"
        raise ArgumentError.new("Status must be either Available or Unavailable.")
      end
      
      
      
    end
    
    def add_trip(trip)
      @trips << trip
    end
    
    def average_rating
      ratings = []
      if trips.length != 0
        trips.each do |trip|
          ratings << trip.rating
        end
        
        return (ratings.sum.to_f / ratings.length).round(2)
      end
      return 0
    end
    
    def total_revenue
      total_amount_made = []
      if trips.length != 0
        trips.each do |trip|
          total_amount_made << trip.cost
        end
        
        return ((total_amount_made.sum.to_f - 1.65) * 0.8).round(2)
      end
      
      return 0
    end
    
    
    private
    
    def self.from_csv(record)
      return new(
        id: record[:id],
        name: record[:name],
        vin: record[:vin],
        status: record[:status]
      )
    end
  end
  
  
end