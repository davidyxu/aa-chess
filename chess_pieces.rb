
class Piece
  attr_accessor :position
  attr_reader :color

  def initialize(board, color)
    @board = board
    @color = color
    @moved = false
  end

  # we can only know if a move leads to check if we switch the color
  def move_leads_to_check?(move)
    preview = @board.preview_board(@position, move)
    @board.check?(@color, preview)
  end

  def possible_moves(pieces = @board.pieces)
  end

  def valid_moves
    possible_moves.reject { |move| move_leads_to_check?(move) }
  end

  def out_of_bounds?(move)
    move[0] < 0 || move[0] > 7 || move[1] < 0 || move[1] > 7
  end

  def overlap_team?(move)
    @board.overlap_position?(move, @color)
  end

  def overlap_enemy?(move)
    @board.overlap_position?(move, opposite_color)
  end

  def opposite_color
    return :black if @color == :white
    :white
  end

  def move(move)
    raise "Invalid move" unless possible_moves.include?(move)
    @moved = true
    unless @board.board[move[0]][move[1]].nil?
      dead_piece = @board.board[move[0]][move[1]]
      remove_dead_piece(dead_piece)
    end
    @board.board[move[0]][move[1]] = self
    @board.board[@position[0]][@position[1]] = nil
    @position = [move[0], move[1]]
  end

  def remove_dead_piece(dead_piece)
    @board.pieces.reject! {|piece| piece == dead_piece}
  end
  def moves_in_one_direction(vector, pieces)
    possible_moves = []
    blocked = false
    move = @position
    until blocked
      move = [move[0]+vector[0], move[1]+vector[1]]
      if blocked(move, pieces)
        blocked = true
      end
      next if out_of_bounds?(move)
      next if overlap_team?(move)
      possible_moves << move
    end
    possible_moves
  end
  def blocked?(move, pieces)
    overlap_enemy?(move,pieces) || out_of_bounds?(move,pieces) || overlap_team?(move, pieces)
  end
end

class King < Piece
  def possible_moves
    possible_moves = []
    [-1,0,1].product([-1,0,1]).each do |vector|
      move = [vector[0]+@position[0], vector[1]+@position[1]]
      next if vector == [0,0]
      next if out_of_bounds?(move)
      next if overlap_team?(move)
      possible_moves << move
    end
    possible_moves
  end
end

class Queen  < Piece
  def possible_moves
    possible_moves = []
    # sorry... we know... we're tired :(
    possible_moves += moves_in_one_direction([1,1])
    possible_moves += moves_in_one_direction([-1,-1])
    possible_moves += moves_in_one_direction([1,-1])
    possible_moves += moves_in_one_direction([-1,1])

    possible_moves += moves_in_one_direction([0,1])
    possible_moves += moves_in_one_direction([0,-1])
    possible_moves += moves_in_one_direction([1,0])
    possible_moves += moves_in_one_direction([-1,0])

    possible_moves
  end

end

class Rook < Piece
  def possible_moves
    possible_moves = []
    possible_moves += moves_in_one_direction([0,1])
    possible_moves += moves_in_one_direction([0,-1])
    possible_moves += moves_in_one_direction([1,0])
    possible_moves += moves_in_one_direction([-1,0])

    possible_moves
    # loop along all 4 directions until we hit a friendly, an enemy, wall
  end
end

class Knight < Piece
  def possible_moves
    moves_one_way([-1,1], [-2,2]) + moves_one_way([-2,2],[-1,1])
  end
  def moves_one_way(vector_row, vector_col)
    possible_moves = []
    vector_row.product(vector_col).each do |vector|
      move = [@position[0]+vector[0], @position[1]+vector[1]]
      next if out_of_bounds?(move)
      next if overlap_team?(move)
      possible_moves << move
    end
    possible_moves
  end
end

class Bishop < Piece
  def possible_moves
    possible_moves = []

    possible_moves += moves_in_one_direction([1,1])
    possible_moves += moves_in_one_direction([-1,-1])
    possible_moves += moves_in_one_direction([1,-1])
    possible_moves += moves_in_one_direction([-1,1])


    possible_moves
  end
end

class Pawn < Piece
  def possible_moves
    direction = -1
    direction = 1 if @color == :black
    possible_moves = []
    move = [@position[0]+direction, @position[1]]
    if !overlap_team?(move) && !overlap_enemy?(move)
      possible_moves << move
      move = [@position[0]+direction*2, @position[1]]
      if !overlap_team?(move) && !overlap_enemy?(move) && @moved == false
        possible_moves << move
      end
    end
    [-1, 1].each do |diagonal_offset|
      move = [@position[0]+direction, @position[1]+diagonal_offset]
      next if out_of_bounds?(move)
      possible_moves << move if overlap_enemy?(move)
    end
    possible_moves
  end
end
