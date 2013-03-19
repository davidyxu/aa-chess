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

  def mate?(color)
    #whether or not player of color has lost
  end
  #pieces
  #
  def valid_move?(position, color)
    valid_moves(color).include?(position)
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
  attr_accessor :position
  attr_reader :color

  def initialize(board, color)
    @board = board
    @color = color
  end

  def valid_moves
    #return a list of possible moves
  end
  def out_of_bounds?(move)
    move[0] < 0 || move[0] > 7 || move[1] < 0 || move[1] > 7
  end
  def overlap_team?(move)
    @board.valid_move?(move, @color)
  end
end

class King < Piece
  def valid_moves
    valid_moves = []
    [-1,0,1].product([-1,0,1]).each do |vector|
      next if vector == [0,0]
      next if out_of_bounds?(move)
      next if overlap_team?(move)
      move = [vector[0]+position[0], vector[1]+position[1]]
      valid_moves << move unless check?(black)
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

end

board = Board.new
test = ChessInterface.new
test.print_board(board.board)