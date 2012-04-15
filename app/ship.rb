module Battleship
  class Ship
    attr_reader :name, :length
    
    def initialize(name, length)
      raise(InvalidShipLengthException, "Length must be between 2 and 5") unless valid_length?(length)
      
      @name   = name
      @length = length
    end
    
    private
    
    def valid_length?(length)
      length.to_i >= 2 && length.to_i <= 5
    end
  end
end
