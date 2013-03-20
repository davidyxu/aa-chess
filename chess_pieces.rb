
class Piece
  attr_accessor :position
  attr_reader :color

  def initialize(board, color)
    @board = board
    @color = color
    @moved = false
  end

  def move_leads_to_check?(move)
    @board.check?(@color, @board.preview_board(@position, move))
  end

  def valid_moves
    valid_moves = []
    valid_moves
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
    raise "Invalid move" unless valid_moves.include?(move)
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
    if dead_piece.color == :black
      @board.black.reject! {|piece| piece == dead_piece}
    else
      @board.white.reject! {|piece| piece == dead_piece}
    end
  end

  def moves_in_one_direction(vector)
    valid_moves = []
    blocked = false
    move = @position
    until blocked
      move = [move[0]+vector[0], move[1]+vector[1]]
      if overlap_enemy?(move) || out_of_bounds?(move)
        blocked = true
      end
      next if out_of_bounds?(move)
      next if overlap_team?(move)
      next if move_leads_to_check?(move)
      valid_moves << move
    end
    valid_moves
  end
end

class King < Piece
  def valid_moves
    valid_moves = []
    [-1,0,1].product([-1,0,1]).each do |vector|
      move = [vector[0]+@position[0], vector[1]+@position[1]]
      next if vector == [0,0]
      next if out_of_bounds?(move)
      next if overlap_team?(move)
      next if move_leads_to_check?(move)
      valid_moves << move
    end
    valid_moves
  end
end

class Queen  < Piece
  def valid_moves
    valid_moves = []
    # sorry... we know... we're tired :(
    valid_moves += moves_in_one_direction([1,1])
    valid_moves += moves_in_one_direction([-1,-1])
    valid_moves += moves_in_one_direction([1,-1])
    valid_moves += moves_in_one_direction([-1,1])

    valid_moves += moves_in_one_direction([0,1])
    valid_moves += moves_in_one_direction([0,-1])
    valid_moves += moves_in_one_direction([1,0])
    valid_moves += moves_in_one_direction([-1,0])

    valid_moves
  end

end

class Rook < Piece
  def valid_moves
    valid_moves = []
    valid_moves += moves_in_one_direction([0,1])
    valid_moves += moves_in_one_direction([0,-1])
    valid_moves += moves_in_one_direction([1,0])
    valid_moves += moves_in_one_direction([-1,0])

    valid_moves
    # loop along all 4 directions until we hit a friendly, an enemy, wall
  end
end

class Knight < Piece
  def valid_moves
    moves_one_way([-1,1], [-2,2]) + moves_one_way([-2,2],[-1,1])
  end
  def moves_one_way(vector_row, vector_col)
    valid_moves = []
    vector_row.product(vector_col).each do |vector|
      move = [@position[0]+vector[0], @position[1]+vector[1]]
      next if out_of_bounds?(move)
      next if overlap_team?(move)
      next if move_leads_to_check?(move)
      valid_moves << move
    end
    valid_moves
  end
end

class Bishop < Piece
  def valid_moves
    valid_moves = []

    valid_moves += moves_in_one_direction([1,1])
    valid_moves += moves_in_one_direction([-1,-1])
    valid_moves += moves_in_one_direction([1,-1])
    valid_moves += moves_in_one_direction([-1,1])


    valid_moves
  end
end

class Pawn < Piece
  def valid_moves
    direction = -1
    direction = 1 if @color == :black
    valid_moves = []
    move = [@position[0]+direction, @position[1]]
    if !overlap_team?(move) && !overlap_enemy?(move)
      valid_moves << move
      move = [@position[0]+direction*2, @position[1]]
      if !overlap_team?(move) && !overlap_enemy?(move) && @moved == false
        valid_moves << move
      end
    end
    [-1, 1].each do |diagonal_offset|
      move = [@position[0]+direction, @position[1]+diagonal_offset]
      next if out_of_bounds?(move)
      valid_moves << move if overlap_enemy?(move)
    end
    valid_moves
  end
end
