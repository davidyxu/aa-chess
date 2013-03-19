# encoding: utf-8

require 'colorize'

class Player
end

class HumanPlayer < Player
end

class ComputerPlayer < Player
end

class ChessInterface
  def initialize #two players
    @unicode_chess = [['♔','♚'],['♕','♛'],['♖','♜'],
                      ['♗','♝'],['♘','♞'],['♙','♟']]
  end
  def background_color(row, col)
    return :white if (row.even? && col.even?) || (row.odd? && col.odd?)
    :black
  end

  def piece_color(square)
    if square.is_a?(NilClass)
      return :white
    else
      return :green if square.color == :white
      return :red  if square.color == :black
    end
  end

  def piece_representation(square)
    case square
    when King then type = @unicode_chess[0]
    when Queen then type = @unicode_chess[1]
    when Rook then type = @unicode_chess[2]
    when Bishop then type = @unicode_chess[3]
    when Knight then type = @unicode_chess[4]
    when Pawn then type = @unicode_chess[5]
    else type = '  '
    end
    if type != '  ' && square.color == :white
      type[0]
    else
      type[1]
    end
  end

  def print_board(board)
    print "   "
    ('a'..'h').each { |col| print " #{col}  ".colorize( :color => :magenta ) }
    print "\n"
    board.each_with_index do |row, row_index|
      print " #{(8-row_index).to_s.colorize( :color => :magenta )} "
      row.each_with_index do |square, col_index|
        color = piece_color(square)
        bg = background_color(row_index, col_index)
        piece = piece_representation(square)
        print " #{piece}  ".colorize( :color => color, :background => bg )
      end
      puts
    end
  end


end

class Chess
  #2 players
  #1 board
  # create the board
  # create the players
  def initialize
    @interface = ChessInterface.new
    @board = Board.new
  end

  def play
    player = :white
    until @board.mate? or @board.draw?
      move = @interface.get_move(player)
      player = color_switch(player)
    end
  end

  def color_switch(color)
    return :black if color == :white
    :white
  end

  def board
    @board.board
  end

end

class Board
  attr_reader :board, :black, :white

  def initialize
    @black = []
    @white = []
    @board = Array.new(8) { Array.new(8) { nil } }
    initialize_board
  end

  def setup_array_and_positions
    2.times do |row|
      8.times do |col|
        @black << @board[row][col]
        @white << @board[row+6][col]
        @board[row][col].position = [row, col]
        @board[row+6][col].position = [row+6, col]
      end
    end
  end

  def initialize_board
    @board[0] = initialize_back_row(:black)
    @board[1].map! { |square| square = Pawn.new(self, :black)}
    @board[6].map! { |square| square = Pawn.new(self, :white)}
    @board[7] = initialize_back_row(:white)
    setup_array_and_positions
  end

  def initialize_back_row(side)
    back_row = []
    back_row << Rook.new(self, side)
    back_row << Knight.new(self, side)
    back_row << Bishop.new(self, side)
    back_row << Queen.new(self, side)
    back_row << King.new(self, side)
    back_row << Bishop.new(self, side)
    back_row << Knight.new(self, side)
    back_row << Rook.new(self, side)
    back_row
  end

  def check?(color, updated_board = @board)
    #whether or not king of color is in check
  end

  def preview_board(start_pos,end_pos)
    future_board = []
    @board.each { |row| future_board << row.dup }
    piece = @board[start_pos[0]][start_pos[1]]
    future_board[start_pos[0]][start_pos[1]] = nil
    future_board[end_pos[0]][end_pos[1]] = piece
    future_board
  end

  def mate?
    #return :black if false#if black checkmates
    #return :white if false#if white checkmates
    false
    #whether or not player of color has lost
  end
  #pieces
  #
  def valid_move?(position, color)
    piece_positions(color).include?(position)
    # on the board
    # not on a current peice of the same color
    # follow the
  end
  def piece_positions(color)
    if color == :white
      @board.white.map {|piece| piece.position }
    else
      @board.black.map {|piece| piece.position }
    end
  end
end

class Piece
  attr_reader :color, :position

  def initialize(board, color)
    @board = board
    @color = color
    @moved = false
  end

  def valid_moves
    valid_moves = []
    valid_moves
  end

  def out_of_bounds?(move)
    move[0] < 0 || move[0] > 7 || move[1] < 0 || move[1] > 7
  end

  def overlap_team?(move)
    @board.valid_move?(move, @color)
  end
  def overlap_enemy?(move)
    @board.valid_move?(move, opposite_color)
  end
  def opposite_color
    if @color == :white
      :black
    else
      :white
    end
  end
  def move(move)
    @moved = true
    raise "Invalid move" if !valid_moves.include?(move)
    unless @board[@position[0]][@position[1]].nil?
      dead_piece = @board[@position[0]][@position[1]]
      if dead_piece.color == :black
        @board.black.reject! {|piece| piece == dead_piece}
      else
        @board.white.reject! {|piece| piece == dead_piece}
      end
      @board[@position[0]][@position[1]] = nil
    end
    @position = [move[0], move[1]]
    @board[move[0]][move[1]] = self
  end
end

class King < Piece
  def valid_moves
    valid_moves = []
    [-1,0,1].product([-1,0,1]).each do |vector|
      move = [vector[0]+position[0], vector[1]+position[1]]
      next if vector == [0,0]
      next if out_of_bounds?(move)
      next if overlap_team?(move)
      next if check?(@color, preview_board(@position, move))
      valid_moves << move
    end
    valid_moves
  end
end

class Queen  < Piece
  def valid_moves
    #return a list of possible moves
  end
end

class Rook < Piece

end

class Knight < Piece

end

class Bishop < Piece

end

class Pawn < Piece
  def valid_moves
    direction = 1
    direction = -1 if @color = :black
    valid_moves = []
    move = [@position[0]+direction, @position[1]]
    if !overlap_team?(move) && !overlap_enemy?(move)
      valid_moves << move
      move = [@position[0]+direction*2, @position[1]]
      valid_moves << move if !overlap_team?(move) && !overlap_enemy?(move)
    end
    [-1, 1].each do |diagonal_offset|
      move = [@position[0]+direction, @position[1]+diagonal_offset]
      valid_moves << move if overlap_enemy?(move)
    end
    # if the pawn has moved and if nothing is blocking it, add the square 2 ahead
    # if nothing is blocking it
    # if a peice is forward and left/right it can take it
    valid_moves
  end
end

board = Board.new
test = ChessInterface.new
test.print_board(board.board)