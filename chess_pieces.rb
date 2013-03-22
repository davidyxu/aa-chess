class Piece
  attr_accessor :position
  attr_reader :color

  def initialize(board, color)
    @board = board
    @color = color
    @moved = false
  end

  def move(move)
    raise "Invalid move" unless possible_moves.include?(move)
    @moved = true
    @board.remove_piece_at(move) unless @board[move].nil?
    @board[move] = self
    @board[@position] = nil
    @position = move
  end

  def move_leads_to_check?(move)
    preview = @board.preview_move(@position, move)
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

  def overlap?(move, pieces, color)
    @board.piece_at_square?(move, color, pieces)
  end
end

class SlidingPiece < Piece

  def sliding_moves(straight, diagonal, pieces)
    vectors = []
    vectors += [[1,0],[-1,0],[0,1],[0,-1]] if straight
    vectors += [[1,-1],[-1,1],[-1,-1],[1,1]] if diagonal
    vectors.inject([]) { |moves, vector| moves + moves_in_one_direction(vector, pieces)}
  end
  def moves_in_one_direction(vector, pieces)
    possible_moves = []

    blocked = false
    move = @position
    until blocked
      move = [move[0]+vector[0], move[1]+vector[1]]
      if blocked?(move, pieces)
        blocked = true
      end
      next if out_of_bounds?(move) || overlap?(move, pieces, @color)
      possible_moves << move
    end
    possible_moves
  end

  def blocked?(move, pieces)
    overlap?(move, pieces, @board.opposite_color(@color)) || out_of_bounds?(move) || overlap?(move, pieces, @color)
  end

end

class King < Piece
  def possible_moves(pieces = @board.pieces)
    possible_moves = []
    # REV: you could combine this method with the knight.
    # I think the only difference would be the vectors you feed it
    [-1,0,1].product([-1,0,1]).each do |vector|
      move = [vector[0]+@position[0], vector[1]+@position[1]]
      next if vector == [0,0]
      next if out_of_bounds?(move)
      next if overlap?(move, pieces, @color)
      possible_moves << move
    end
    possible_moves
  end
  def castling(pieces)

  end
end

class Queen < SlidingPiece
  def possible_moves(pieces = @board.pieces)
    sliding_moves(true, true, pieces)
  end

end

class Rook < SlidingPiece
  def possible_moves(pieces = @board.pieces)
    sliding_moves(true, false, pieces)
  end
end

class Knight < Piece
  def possible_moves(pieces = @board.pieces)
    moves_one_way([-1,1], [-2,2],pieces) + moves_one_way([-2,2],[-1,1],pieces)
  end
  def moves_one_way(vector_row, vector_col, pieces)
    possible_moves = []
    vector_row.product(vector_col).each do |vector|
      move = [@position[0]+vector[0], @position[1]+vector[1]]
      next if out_of_bounds?(move)
      next if overlap?(move, pieces, @color)
      possible_moves << move
    end
    possible_moves
  end
end

class Bishop < SlidingPiece
  def possible_moves(pieces = @board.pieces)
    sliding_moves(false, true, pieces)
  end
end

class Pawn < Piece
  def possible_moves(pieces = @board.pieces)
    direction = -1
    direction = 1 if @color == :black
    possible_moves = []
    move = [@position[0]+direction, @position[1]]
    if !overlap?(move, pieces, @color) && !overlap?(move, pieces, @board.opposite_color(@color))
      possible_moves << move
      move = [@position[0]+direction*2, @position[1]]
      if !overlap?(move, pieces, @color) && !overlap?(move, pieces, @board.opposite_color(@color)) && @moved == false
        possible_moves << move
      end
    end
    [-1, 1].each do |diagonal_offset|
      move = [@position[0]+direction, @position[1]+diagonal_offset]
      next if out_of_bounds?(move)
      possible_moves << move if overlap?(move, pieces, @board.opposite_color(@color))
    end
    possible_moves
  end
end
