require_relative './battleship_cli'

puts "Enter player 1's name"
player1 = Battleship::Player.new(gets.gsub("\n", ''))

puts "Enter player 2's name"
player2 = Battleship::Player.new(gets.gsub("\n", ''))

players = [player1, player2]
players.each_with_index do |player, index|
  player.opponent = players[(index + 1) % 2]
  setup_board(player)
end
player1.opponent = player2
player2.opponent = player1

game_over = false
turn = 0
while !game_over
  current_player = players[(turn % 2)]
  
  if take_turn(current_player)
    puts "#{current_player.name} won!"
    game_over = true
  end
  
  turn += 1
end
