require 'ship'

module Battleship
  class Board
    attr_reader :shots, :rows
    
    def initialize(*args)
      @rows  = []
      10.times { @rows << (col = Array.new(10)) }
      @ships = []
      @shots = []
    end
    
    def row(i)
      @rows[i]
    end
    
    def col(i)
      @rows.collect { |col| col[i] }
    end
    
    def target(coordinates)
      normalized_coordinates = normalize_coordinates(coordinates)
      raise(DuplicateMoveException, "You've already tried #{coordinates}") if shot_made?(normalized_coordinates)
      
      @shots << normalized_coordinates
    end
    
    def place_ship(ship, bow_coordinates, direction)
      raise(InvalidDirectionException, "Only '[E]ast' and '[S]outh' are allowed as directions") unless (direction = direction.to_s.downcase) =~ /^[es]/
      
      normalized_position = normalize_coordinates(bow_coordinates)
      place_horizontal(ship, normalized_position) if direction.to_s =~ /^e/
      place_vertical(ship, normalized_position) if direction.to_s =~ /^s/
      
      return true
    end
    
    private
    
    def normalize_coordinates(coordinates)
      row, col = split_coordinates(coordinates)
      
      row = %w(1 2 3 4 5 6 7 8 9 10).index(row)
      col = %w(A B C D E F G H I J).index(col.to_s.upcase)
      raise(OutOfBoundsException, "Coordinates can only be within A-J and 1-10") if coordinates_out_of_bounds?([row, col])
      
      return [row, col]
    end
    
    def split_coordinates(coordinates)
      row = (coordinates.to_s.match(/\d+/) || [])[0]
      col = (coordinates.to_s.match(/[a-jA-J]/) || [])[0]
      
      return [row, col]
    end
    
    def coordinates_out_of_bounds?(coordinates)
      raise "Expecting an array" unless coordinates.is_a?(Array)
      
      coordinates.any? { |val| val.nil? || val < 0 || val > 10 }
    end
    
    def shot_made?(coordinates)
      raise "Expecting an array" unless coordinates.is_a?(Array)
      
      @shots.include?(coordinates)
    end
    
    def place_horizontal(ship, bow_coordinates)
      bow_y, bow_x = bow_coordinates
      selected_row = row(bow_y)
      raise(InvalidShipPositionException, "This position would place the ship off the board") if bow_x + ship.length > selected_row.length
      
      ship.length.times do |i|
        place_ship_position(ship, bow_y, bow_x + i)
      end
    end
    
    def place_vertical(ship, bow_coordinates)
      bow_y, bow_x = bow_coordinates
      selected_col = col(bow_x)
      raise(InvalidShipPositionException, "This position would place the ship off the board") if bow_y + ship.length > selected_col.length
      
      ship.length.times do |i|
        place_ship_position(ship, (bow_y + i), bow_x)
      end
    end
    
    def place_ship_position(ship, y, x)
      raise(InvalidShipPositionException, "This position is occupied by the #{ship.name}") if @rows[y][x].is_a?(Ship)
      @rows[y][x] = ship 
    end
  end
end
