require_relative '../spec_helper'
require 'socket_player'

module SocketPlayerSpecHelper
  def set_board(player)
    player.ship_positions = [['D', ['A1', 'e']], ['S', ['G6', 'e']], ['C', ['F1', 's']], ['B', ['E1', 's']], ['A', ['J3', 's']]]
  end
end

describe Battleship::SocketPlayer do
  include SocketPlayerSpecHelper
  let(:socket_player) { Battleship::SocketPlayer.new }
  
  it "should be able to set ship positions by taking in an array of data" do
    set_board(socket_player)
    
    destroyer   = socket_player.ship_board.ships[0]
    submarine   = socket_player.ship_board.ships[1]
    cruiser     = socket_player.ship_board.ships[2]
    battleship  = socket_player.ship_board.ships[3]
    carrier     = socket_player.ship_board.ships[4]
    
    socket_player.ship_board.rows.should == [
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
  
  it "should be able to represent the board as a JSON string" do
    set_board(socket_player)
    
    socket_player.ship_board_as_json.should == [
      # A |  B |  C |  D |  E |  F |  G |  H |  I |  J |
      ['D', 'D', nil, nil, 'B', 'C', nil, nil, nil, nil], #  1
      [nil, nil, nil, nil, 'B', 'C', nil, nil, nil, nil], #  2
      [nil, nil, nil, nil, 'B', 'C', nil, nil, nil, 'A'], #  3
      [nil, nil, nil, nil, 'B', nil, nil, nil, nil, 'A'], #  4
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, 'A'], #  5
      [nil, nil, nil, nil, nil, nil, 'S', 'S', 'S', 'A'], #  6
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, 'A'], #  7
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], #  8
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], #  9
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]  # 10
    ].to_json
  end
  
  it "should be able to represent a board with hits and misses" do
    puts socket_player.target_board_as_json
    ('A'..'G').each do |col|
      (2..6).each do |row|
        socket_player.target_board.record_shot("#{col}#{row}") { false }
      end
    end
    socket_player.target_board.record_shot("I4") { true }
    socket_player.target_board.record_shot("I5") { true }
    socket_player.target_board.record_shot("I6") { 'Cruiser' }
    
    socket_player.target_board_as_json.should == [
      # A |  B |  C |  D |  E |  F |  G |  H |  I |  J |
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], #  1
      ['M', 'M', 'M', 'M', 'M', 'M', 'M', nil, nil, nil], #  2
      ['M', 'M', 'M', 'M', 'M', 'M', 'M', nil, nil, nil], #  3
      ['M', 'M', 'M', 'M', 'M', 'M', 'M', nil, 'H', nil], #  4
      ['M', 'M', 'M', 'M', 'M', 'M', 'M', nil, 'H', nil], #  5
      ['M', 'M', 'M', 'M', 'M', 'M', 'M', nil, 'H', nil], #  6
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], #  7
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], #  8
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], #  9
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]  # 10
    ].to_json
  end
end
