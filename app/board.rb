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
    
    def record_shot(coordinates)
      normalized_coordinates = normalize_coordinates(coordinates)
      row_y, row_x = normalized_coordinates
      raise(DuplicateMoveException, "You've already tried #{coordinates}") if shot_made?(normalized_coordinates)
      
      result = yield
      @shots << normalized_coordinates
      @rows[row_y][row_x] = result ? :hit : :miss
      
      return result
    end
    
    def target(coordinates)
      normalized_coordinates = normalize_coordinates(coordinates)
      
      row_y, row_x = normalized_coordinates
      if ship = @rows[row_y][row_x]
        ship.hit!
        return(ship.sunk? ? ship.name : true)
      else
        return false
      end
    end
    
    def place_ship(ship, bow_coordinates, direction)
      raise(InvalidShipDirectionException, "Only '[E]ast' and '[S]outh' are allowed as directions") unless (direction = direction.to_s.downcase) =~ /^[es]/
      
      normalized_position = normalize_coordinates(bow_coordinates)
      place_horizontal(ship, normalized_position) if direction.to_s =~ /^e/
      place_vertical(ship, normalized_position) if direction.to_s =~ /^s/
      
      return true
    end
    
    def unsunk_ships
      @ships = []
      @rows.each do |column|
        column.each do |cell|
          @ships << cell if cell.is_a?(Ship) && !cell.sunk?
        end
      end
      
      return @ships
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
      
      validate_ship_placement(ship.length, bow_coordinates, :horizontal)
      
      ship.length.times do |i|
        place_ship_position(ship, bow_y, bow_x + i)
      end
    end
    
    def place_vertical(ship, bow_coordinates)
      bow_y, bow_x = bow_coordinates
      selected_col = col(bow_x)
      raise(InvalidShipPositionException, "This position would place the ship off the board") if bow_y + ship.length > selected_col.length
      
      validate_ship_placement(ship.length, bow_coordinates, :vertical)
      
      ship.length.times do |i|
        place_ship_position(ship, (bow_y + i), bow_x)
      end
    end
    
    def validate_ship_placement(ship_length, coordinates, orientation)
      validation_method = orientation == :vertical ? :validate_vertical_placement : :validate_horizontal_placement
      
      ships = send(validation_method, ship_length, coordinates).compact
      raise(InvalidShipPositionException, "This position would overlap the #{ships[0].name}") unless ships.empty?
    end
    
    def validate_horizontal_placement(ship_length, coordinates)
      bow_y, bow_x = coordinates
      ships = []
      ship_length.times do |i|
        ships << has_ship?(bow_y, bow_x + i)
      end
      
      return ships
    end
    
    def validate_vertical_placement(ship_length, coordinates)
      bow_y, bow_x = coordinates
      ships = []
      ship_length.times do |i|
        ships << has_ship?(bow_y + i, bow_x)
      end
      
      return ships
    end
    
    def has_ship?(y, x)
      @rows[y][x]
    end
    
    def place_ship_position(ship, y, x)
      
      @rows[y][x] = ship 
    end
  end
end
