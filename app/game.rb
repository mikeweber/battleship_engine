module Battleship
  class BattleshipException < Exception; end
  class OutOfBoundsException < BattleshipException; end
  class DuplicateMoveException < BattleshipException; end
  class InvalidShipLengthException < BattleshipException; end
  class InvalidShipPositionException < BattleshipException; end
end

require 'board'
