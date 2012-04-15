require_relative './main'

def setup_board(player)
  ships.each do |ship|
    placed = false
    while !placed
      placed = place_ship(player, ship)
    end
  end
end

def setup_board(player)
  positions = if player.name == "M"
    [
      ['A1', 'east'],
      ['G6', 'east'],
      ['F1', 'south'],
      ['E1', 'south'],
      ['J3', 'south']
    ]
  else
    [
      ['C1', 'east'],
      ['G6', 'east'],
      ['F3', 'south'],
      ['E3', 'south'],
      ['J5', 'south']
    ]
  end
  
  ships.zip(positions).each do |ship, pos_dir|
    pos, dir = pos_dir
    puts "Placing #{ship.name} at #{pos} facing #{dir}"
    player.place_ship(ship, pos, dir) unless pos_dir.nil?
  end
end

def place_ship(player, ship)
  puts "Where do you want to place your #{ship.name}, which is #{ship.length} spaces long? (specify letter/number coordinates e.g. J4)"
  position = gets
  puts "What direction would you like to place your #{ship.name}? ([E]ast or [S]outh)"
  direction = gets
  begin
    player.place_ship(ship, position, direction)
    print_board(player)
    return true
  rescue Battleship::BattleshipException => e
    puts e.message
    return false
  end
end

def take_turn(player)
  puts "#{player.name}'s shot board"
  puts print_target_board(player)
  puts "#{player.name}: place your shot (specify letter/number coordinates e.g. J4)"
  turn_over = false
  while !turn_over
    begin
      result = player.take_turn(gets)
    
      if !result
        puts "Miss"
      elsif result == true
        puts "Hit!"
      else
        puts "You sunk my #{result}"
      end
    
      turn_over = true
    rescue Battleship::BattleshipException => e
      puts e.message
    end
  end

  return player.won?
end

def ships
  [
    Battleship::Ship.new("Destroyer", 2),
    Battleship::Ship.new("Submarine", 3),
    Battleship::Ship.new("Cruiser", 3),
    Battleship::Ship.new("Battleship", 4),
    Battleship::Ship.new("Aircraft carrier", 5)
  ]
end

def print_ship_board(player)
  print_board(player.ship_board) do |cell|
    cell.is_a?(Battleship::Ship) ? cell.short_name : ' '
  end
end

def print_target_board(player)
  print_board(player.target_board) do |cell|
    if cell == :hit
      'X'
    elsif cell == :miss
      '-'
    else
      ' '
    end
  end
end

def print_board(board)
  board_outline = "   ABCDEFGHIJ"
  board.rows.each_with_index do |row, index|
    row_as_string = "#{(index + 1).to_s.ljust(2)}["
    row.each do |cell|
      row_as_string << yield(cell)
    end
    row_as_string << ']'
    
    board_outline << "\n#{row_as_string}"
  end
  
  board_outline
end

