require 'board'

module Battleship
  class Player
    attr_reader :name, :ship_board, :target_board, :opponent
    
    def initialize(name = "Player")
      @name = name
      @ship_board = Board.new
      @target_board = Board.new
    end
    
    def place_ship(ship, position, direction)
      @ship_board.place_ship(ship, position, direction)
    end
    
    def opponent=(player)
      @opponent = player
    end
    
    def take_turn(position)
      @target_board.record_shot(position) do
        @opponent.take_shot(position)
      end
    end
    
    def take_shot(position)
      @ship_board.target(position)
    end
    
    def remaining_ships
      self.ship_board.unsunk_ships
    end
    
    def won?
      self.opponent.remaining_ships.empty?
    end
  end
end
