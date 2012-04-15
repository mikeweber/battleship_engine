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
    }.should raise_error(Battleship::InvalidShipLengthException)
    lambda {
      Battleship::Ship.new("Alien mothership", 6)
    }.should raise_error(Battleship::InvalidShipLengthException)
  end
  
  context "when assigning hits" do
    let(:destroyer) { Battleship::Ship.new("Destroyer", 2) }
    
    it "should know how many times its been hit" do
      expect {
        destroyer.hit!
      }.to change(destroyer, :hit_count).by(1)
    end
    
    it "should know when its sunk" do
      destroyer.hit!
      expect {
        destroyer.hit!
      }.to change(destroyer, :sunk?).from(false).to(true)
    end
  end
end
