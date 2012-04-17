require 'player'

module Battleship
  class SocketPlayer < Player
    attr_accessor :opponent_socket
    
    def ship_positions=(positions)
      positions.each do |ship_initial, pos_and_dir|
        if pos_and_dir.reject { |el| el.nil? || el.empty? }.size == 2 && (ship = self.ship_board.ships.detect { |a_ship| a_ship.short_name == ship_initial })
          self.place_ship(ship, *pos_and_dir)
        end
      end
    end
    
    def to_json(*args)
      {
        :name       => self.name,
        :ship_board => short_ship_names,
        :shot_board => status_names
      }.to_json(args)
    end
    
    private
    
    def short_ship_names
      self.ship_board.rows.collect do |row|
        row.collect { |cell| cell.short_name if cell.is_a?(Ship) }
      end
    end
    
    def status_names
      self.target_board.rows.collect do |row|
        row.collect { |cell| cell.nil? ? nil : cell.to_s[0..0].upcase }
      end
    end
  end
end
