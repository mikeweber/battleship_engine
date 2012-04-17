var websocket_port = 8080,
    websocket_conn = null,
    player_index = 0

$(function() {
  websocket_conn = openGameSocket()
  
  $('form.socket_form').on("submit", function(event) {
    event.preventDefault()
    // var initial_board = buildBoardJSON($(this).find('[name^="ships"]'))
    var name_field = $(this).find('input[name="name"]')
    var board = buildBoardJSON($(this).find('select'))
    startGame(name_field.val(), board)
    name_field.attr('disabled', 'disabled')
  })
  $('form.socket_form select').on("change", function(event) {
    var board = buildBoardJSON($(this).parent('form').find('select'))
    websocket_conn.send(JSON.stringify({ 'type': 'draw_board', 'ship_positions': board }))
  })
  
  $('#shot_board tbody td').on("click", takeTheShot)
  $('input[name="name"]').focus()
});

function takeTheShot(event) {
  var coord = $(this).attr('data-coord')
  
  if (!coord) return
  console.log("Missles hot! Shooting " + coord)
  websocket_conn.send(JSON.stringify({ 'type': 'make_move', 'player_index': player_index, 'move': coord }))
}

function buildBoardJSON(fields) {
  var ship_positions = {}
  fields.each(function() {
    var ship = $(this).attr('name').match(/^ships\[(\w)\]/)[1]
    
    if (!ship_positions[ship]) {
      ship_positions[ship] = { 'pos': '', 'direction': '' }
    }
    var select_val = $(this).val()
    var pos_match = $(this).attr('name').match(/^ships\[\w\]\[(col|row)\]/)
    var dir_match = $(this).attr('name').match(/^ships\[\w\]\[direction\]/)
    if (pos_match) {
      ship_positions[ship].pos += select_val
    } else if (dir_match) {
      ship_positions[ship].direction += select_val
    }
  })  
  var ship_array = []
  $(Object.keys(ship_positions)).each(function() {
    var pos_dir = ship_positions[this]
    ship_array.push([this.toString(), [pos_dir.pos.toString(), pos_dir.direction.toString()]])
  })
  
  return ship_array
}

function drawShipBoard(board) {
  if (!board) return
  
  var game_board_table = $('#ship_board')
  $(board).each(function(row) {
    $(this).each(function(col) {
      var tr_row = $(game_board_table.find('tbody tr')[row])
      var cell = $(tr_row.find('td')[col + 1])
      if (['A', 'B', 'C', 'D', 'S'].indexOf(this.toString()) >= 0) {
        cell.addClass('has_ship')
      } else {
        cell.removeClass('has_ship')
      }
    })
  })
}

function drawShotBoard(board) {
  if (!board) return
  
  var shot_board_table = $('#shot_board')
  $(board).each(function(row) {
    $(this).each(function(col) {
      var tr_row = $(shot_board_table.find('tbody tr')[row]),
          cell = $(tr_row.find('td.coordinate')[col]),
          peg = cell.find('.peg')
      
      if (peg.length == 0){
        peg = $('<div>').addClass('peg')
        cell.append(peg)
      }
      if (this.toString() == 'H') {
        peg.addClass('hit')
      } else if (this.toString() == 'M') {
        peg.addClass('miss')
      }
    })
  })
}

function startGame(name, positions) {
  websocket_conn.send(JSON.stringify({ 'type': 'register', 'name': name, 'ship_positions': positions }))
}

function openGameSocket() {
  var connection = newWebSocket("ws://" + document.location.hostname + ":" + websocket_port)
  
  connection.onopen = function(event) {
  }
  
  connection.onmessage = function(event) {
    var msg = JSON.parse(event.data)
    
    var user_message
    if (msg.type == 'play_game') {
      player_index = msg.player_index
      if (msg.player) drawShipBoard(msg.player.ship_board)
    }
    
    if (msg.error) {
      $('#game_message').html(msg.error).addClass('error')
    } else if (msg.type == 'draw_board' && msg.player) {
      console.log(msg.player.ship_board)
      drawShipBoard(msg.player.ship_board)
    } else if (msg.game_over) {
      user_message = msg.game_over
      $('#shot_board').removeClass('my_turn')
      closeWebSocket(connection)
    } else if (msg.your_turn) {
      user_message = "It's your turn."
      $('#shot_board').addClass('my_turn')
    } else if (msg.your_turn == false) {
      user_message = "Now it's your opponents turn."
      $('#shot_board').removeClass('my_turn')
    }
    if (msg.last_shot) {
      new_message = "The last shot, " + msg.last_shot + " was a " + msg.result
      if (msg.ship_sunk) new_message += " and it sunk the " + msg.ship_sunk
      user_message = new_message + ". " + user_message
    }
    if (msg.player) drawShotBoard(msg.player.shot_board)
    $('#game_message').html(user_message).removeClass('error')
  }
  
  connection.onclose = function(event) {
  }
  
  return connection
}

function newWebSocket(url, protocols) {
  var socket
  if ("MozWebSocket" in window) {
    socket = new MozWebSocket(url, protocols)
  } else if ("WebSocket" in window) {
    socket = new WebSocket(url, protocols)
  }
  
  return socket
}

function closeWebSocket(connection) {
  connection.close()
}
