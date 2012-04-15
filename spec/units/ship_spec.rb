require_relative '../spec_helper'

describe Battleship::Ship do
  it "should have a name and length between 2 and 5" do
    Battleship::Ship.new("Destroyer", 2).length.should == 2
    Battleship::Ship.new("Submarine", 3).length.should == 3
    Battleship::Ship.new("Cruiser", 3).length.should == 3
    Battleship::Ship.new("Battleship", 4).length.should == 4
    Battleship::Ship.new("Aircraft carrier", 5).length.should == 5
    
    lambda {
      Battleship::Ship.new("Shrimp Boat", 1)
    }.should raise_error(InvalidShipLengthException)
    lambda {
      Battleship::Ship.new("Alien mothership", 6)
    }.should raise_error(InvalidShipLengthException)
  end
end
