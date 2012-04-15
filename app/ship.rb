module Battleship
  class Ship
    attr_reader :name, :length, :hit_count
    
    def initialize(name, length)
      raise(InvalidShipLengthException, "Length must be between 2 and 5") unless valid_length?(length)
      
      @name       = name
      @length     = length
      @hit_count  = 0
    end
    
    def short_name
      self.name[0..0]
    end
    
    def hit!
      @hit_count += 1 unless self.sunk?
    end
    
    def sunk?
      self.hit_count >= self.length
    end
    
    private
    
    def valid_length?(length)
      length.to_i >= 2 && length.to_i <= 5
    end
  end
end
