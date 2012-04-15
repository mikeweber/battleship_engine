require_relative '../spec_helper'

describe Battleship::Board do
  let(:board) { Battleship::Board.new }
  
  context "when normalizing coordinates" do
    it "should convert a letter/number coordinate to row/column" do
      board.send(:normalize_coordinates, "A1").should  == [0, 0]
      board.send(:normalize_coordinates, "E1").should  == [0, 4]
      board.send(:normalize_coordinates, "J1").should  == [0, 9]
      board.send(:normalize_coordinates, "E5").should  == [4, 4]
      board.send(:normalize_coordinates, "E10").should == [9, 4]
      board.send(:normalize_coordinates, "J10").should == [9, 9]
    end
    
    it "should convert a number/letter coordinate to row/column" do
      board.send(:normalize_coordinates, "1A").should  == [0, 0]
      board.send(:normalize_coordinates, "1E").should  == [0, 4]
      board.send(:normalize_coordinates, "1J").should  == [0, 9]
      board.send(:normalize_coordinates, "5E").should  == [4, 4]
      board.send(:normalize_coordinates, "10E").should == [9, 4]
      board.send(:normalize_coordinates, "10J").should == [9, 9]
    end
    
    it "should be able to target with lowercase letters" do
      board.send(:normalize_coordinates, "1a").should  == [0, 0]
      board.send(:normalize_coordinates, "1e").should  == [0, 4]
      board.send(:normalize_coordinates, "1j").should  == [0, 9]
      board.send(:normalize_coordinates, "5e").should  == [4, 4]
      board.send(:normalize_coordinates, "10e").should == [9, 4]
      board.send(:normalize_coordinates, "10j").should == [9, 9]
    end
  end
  
  it "should be able to target a row/column coordinate" do
    board.target("A1")
  end
  
  it "should not allow picking an out of bounds coordinate" do
    lambda { board.target("A11") }.should raise_error(Battleship::OutOfBoundsException)
    lambda { board.target("K1") }.should raise_error(Battleship::OutOfBoundsException)
    lambda { board.target("K11") }.should raise_error(Battleship::OutOfBoundsException)
  end
  
  context "when placing pieces" do
    let(:carrier)   { Battleship::Ship.new("Aircraft Carrier", 5) }
    let(:destroyer) { Battleship::Ship.new("Destroyer", 2) }
    
    it "should be able to place a ship on the board" do
      board.place_ship(carrier, "A1", 'east')
    end
    
    it "should be able to place a board horizontally" do
      board.send(:place_horizontal, carrier, [0, 1])
      first_row = board.row(0)
      first_row.should == [nil, carrier, carrier, carrier, carrier, carrier, nil, nil, nil, nil]
      
      board.send(:place_horizontal, destroyer, [9, 8])
      ninth_row = board.row(9)
      ninth_row.should == [nil, nil, nil, nil, nil, nil, nil, nil, destroyer, destroyer]
    end
    
    it "should not be able to place a horizontal ship off the right" do
      lambda { board.send(:place_horizontal, destroyer, [9, 9]) }.should raise_error(Battleship::InvalidShipPositionException)
    end
    
    it "should be able to place a board vertically" do
      board.send(:place_vertical, carrier, [0, 1])
      second_col = board.col(1)
      second_col.should == [carrier, carrier, carrier, carrier, carrier, nil, nil, nil, nil, nil]
      
      board.send(:place_vertical, destroyer, [8, 9])
      ninth_row = board.col(9)
      ninth_row.should == [nil, nil, nil, nil, nil, nil, nil, nil, destroyer, destroyer]
    end
    
    it "should not be able to place a vertical ship off the bottom" do
      lambda { board.send(:place_vertical, destroyer, [9, 9]) }.should raise_error(Battleship::InvalidShipPositionException)
    end
    
    it "should not be able to overlap pieces" do
      board.place_ship(carrier, 'A2', 'east')
      lambda { board.place_ship(destroyer, 'E1', 'south') }.should raise_error(Battleship::InvalidShipPositionException)
    end
    
    it "should be able to set an entire board" do
      submarine   = Battleship::Ship.new("Submarine", 3)
      cruiser     = Battleship::Ship.new("Cruiser", 3)
      battleship  = Battleship::Ship.new("Battleship", 4)
      
      board.place_ship(destroyer,   'A1', 'east')
      board.place_ship(battleship,  'E1', 'south')
      board.place_ship(cruiser,     'F1', 'south')
      board.place_ship(submarine,   'G6', 'east')
      board.place_ship(carrier,     'J3', 'south')
      
      board.rows.should == [
        #     A     |     B     |     C     |     D     |     E     |     F     |     G     |     H     |     I     |     J     |
        [ destroyer,  destroyer,        nil,        nil, battleship,    cruiser,        nil,        nil,        nil,        nil], #  1
        [       nil,        nil,        nil,        nil, battleship,    cruiser,        nil,        nil,        nil,        nil], #  2
        [       nil,        nil,        nil,        nil, battleship,    cruiser,        nil,        nil,        nil,    carrier], #  3
        [       nil,        nil,        nil,        nil, battleship,        nil,        nil,        nil,        nil,    carrier], #  4
        [       nil,        nil,        nil,        nil,        nil,        nil,        nil,        nil,        nil,    carrier], #  5
        [       nil,        nil,        nil,        nil,        nil,        nil,  submarine,  submarine,  submarine,    carrier], #  6
        [       nil,        nil,        nil,        nil,        nil,        nil,        nil,        nil,        nil,    carrier], #  7
        [       nil,        nil,        nil,        nil,        nil,        nil,        nil,        nil,        nil,        nil], #  8
        [       nil,        nil,        nil,        nil,        nil,        nil,        nil,        nil,        nil,        nil], #  9
        [       nil,        nil,        nil,        nil,        nil,        nil,        nil,        nil,        nil,        nil]  # 10
      ]
    end
  end
  
  context "when targeting" do
    it "should track shots" do
      expect {
        board.target("A1")
      }.to change(board.shots, :size).by(1)
    end
    
    it "should be not able target the same coordinate twice" do
      board.target("A1")
      expect {
        lambda { board.target("A1") }.should raise_error(Battleship::DuplicateMoveException)
      }.to_not change(board.shots, :size)
    end
  end
end
