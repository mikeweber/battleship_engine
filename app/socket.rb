require_relative './main'
require 'socket_player'
require 'em-websocket'

@players = []

EventMachine.run {
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |ws|
    ws.onopen {
      puts "WebSocket connection open"
    }
    
    ws.onclose {
      @players.each do |player, socket|
        socket.send({ :game_over => "Your opponent left; draw" }.to_json)
      end
      @players.clear
      @player_turn = nil
    }
    
    ws.onmessage { |msg|
      puts msg.inspect
      msg = JSON.parse(msg)
      puts msg.inspect
      
      case msg['type']
        when 'draw_board'
          temp_player = Battleship::SocketPlayer.new
          begin
            temp_player.ship_positions = msg['ship_positions']
            ws.send({ :type => 'draw_board', :player => temp_player }.to_json)
          rescue Battleship::BattleshipException => e
            ws.send({ :error => e.message }.to_json)
          end
        when 'register'
          puts "Registering #{msg['name']}"
          if @players.size <= 1
            new_player = Battleship::SocketPlayer.new(msg['name'])
            new_player.ship_positions = msg['ship_positions']
            @players << [new_player, ws]
          end
          if @players.size == 2
            puts "Game is ready!"
            @player_turn = 0
            @players.each_with_index do |player_and_socket, index|
              player, player_socket = player_and_socket
              opponent_index = (index + 1) % 2
              puts opponent_index
              puts @players[opponent_index].inspect
              player.opponent, player.opponent_socket = @players[opponent_index]
              puts player.opponent
              puts "#{player.name}'s opponent is #{player.opponent.name}"
              player_socket.send({ :type => 'play_game', :player_index => index, :your_turn => (index % 2 == 0), :player => player }.to_json)
            end
          end
        when 'make_move'
          if @player_turn
            player_index = msg['player_index'].to_i
            if player_index == (@player_turn % 2)
              current_player, player_socket = @players[player_index]
              opponent, opponent_socket = [current_player.opponent, current_player.opponent_socket]
              puts "#{current_player.name} is making a move"
            
              valid_shot = true
              begin
                shot_result = current_player.take_turn(msg['move'])
              rescue Battleship::BattleshipException => e
                player_socket.send({ :error => e.message }.to_json)
                valid_shot = false
              end
            
              if valid_shot
                @player_turn += 1
              
                default_message = { :last_shot => msg['move'], :result => (shot_result ? :hit : :miss), :ship_sunk => (shot_result if shot_result.is_a?(String)) }
                unless current_player.won?
                  player_message    = { :your_turn => false, :player => current_player }.merge(default_message)
                  opponent_message  = { :your_turn => true,  :player => opponent }.merge(default_message)
                
                  player_socket.send(player_message.to_json)
                  opponent_socket.send(opponent_message.to_json)
                else
                  player_socket.send(  { :game_over => 'You win!', :player => current_player }.merge(default_message).to_json)
                  opponent_socket.send({ :game_over => 'You lost', :player => opponent }.merge(default_message).to_json)
                end
              end
            end
          end
      end
    }
  end
}
