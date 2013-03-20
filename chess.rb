# encoding: utf-8

require 'colorize'
require_relative 'chess_pieces'
class Player
end

class HumanPlayer < Player
  def initialize(color)
    @color = color
    @letter_to_column = {}
    ('a'..'h').each_with_index do |letter, column|
      @letter_to_column[letter] = column
    end
  end

  def get_move
    begin
      puts "It is #{@color}'s turn, please select a piece to move:"
      command = gets.chomp
    end until (/\A[a-h][1-8]\z/i).match(command)
    start_position = input_to_array(command.split(''))
    begin
      puts "It is #{@color}'s turn, please select a place to move to:"
      command = gets.chomp
    end until (/\A[a-h][1-8]\z/i).match(command)
    end_position = input_to_array(command.split(''))
    [start_position, end_position]
  end

  def input_to_array(command)
    move = []
    move[0] = 8 - command[1].to_i
    move[1] = @letter_to_column[command[0]]
    move
  end
end

class ComputerPlayer < Player

end

class ChessInterface
  def initialize #two players
    @white = HumanPlayer.new(:white)
    @black = HumanPlayer.new(:black)
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

  def print_check_message(turn)
    puts "#{turn.capitalize} is in check!"
  end

  def get_move(turn)
    if turn == :white
      @white.get_move
    else
      @black.get_move
    end
  end

  def display_results(winner)
    if winner == :draw
      puts "The game is a draw."
    else
      puts "#{winner.capitalize} is the winner"
    end
  end
end

class Chess
  def initialize
    @board = Board.new
    @interface = ChessInterface.new
    play
  end

  def play
    turn = :white
    until @board.game_over
      begin
        @interface.print_check_message(turn) if @board.check?(turn)
        @interface.print_board(@board.board)
        move = @interface.get_move(turn)
      end until valid_move_selected?(move, turn)
      @board.move_piece(move[0], move[1])
      turn = switch_turn(turn)
    end
    end_message
  end

  def valid_move_selected?(move, turn)
    start_position = move[0]
    piece = @board.board[start_position[0]][start_position[1]]
    @board.overlap_position?(move[0], turn) && piece.valid_moves.include?(move[1])
  end

  def switch_turn(color)
    color == :white ? :black : :white
  end

  def end_message
    @interface.display_results(@board.game_over)
  end
end

class Board
  attr_reader :board, :pieces

  def initialize
    @pieces = []
    @board = Array.new(8) { Array.new(8) { nil } }
    initialize_board
  end

  def setup_array_and_positions
    2.times do |row|
      8.times do |col|
        @pieces << @board[row][col]
        @pieces << @board[row+6][col]
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

  def white(pieces = @pieces)
    pieces.select { |piece| piece.color == :white}
  end

  def black(pieces = @pieces)
    pieces.select { |piece| piece.color == :black}
  end

  def check?(color, pieces = @pieces)
    if color == :black
      enemy = white(pieces)
      #enemy_moves = move_set(:white, pieces)
      king = black(pieces).select { |piece| piece.is_a?(King) }[0]
    elsif color == :white
      enemy = black(pieces)
      #enemy_moves = move_set(:black, pieces)
      king = white(pieces).select { |piece| piece.is_a?(King) }[0]
    end
    enemy_moves = enemy.inject([]) { |moves, piece| moves + piece.possible_moves(pieces) }
    enemy_moves.include?(king.position)
  end

  def preview_move(start_pos,end_pos)
    future_pieces = @pieces.map { |piece| piece.dup }
    moved_piece = future_pieces.select { |piece| piece.position == start_pos}[0]
    future_pieces.reject! { |piece| piece.position == end_pos }
    moved_piece.position = end_pos
    future_pieces
  end

  def game_over
    winner = false
    winner = :white if mate?(:black)
    winner = :black if mate?(:white)
    winner = :draw if draw?
    winner
  end

  def draw?
    false
  end

  def move_set(color, pieces = @pieces)
    player_pieces = white(pieces) if color == :white
    player_pieces = black(pieces) if color == :black
    player_pieces.inject([]) { |moves, piece| moves + piece.valid_moves }
  end

  def mate?(color)
    return :black if move_set(:black).empty?
    return :white if move_set(:white).empty?
    false
  end

  def overlap_position?(position, color, pieces = @pieces)
    piece_positions(color, pieces).include?(position)
  end

  def piece_positions(color, pieces)
    if color == :both
      positions = pieces.map { |piece| piece.position }
    elsif color == :white
      positions = white(pieces).map {|piece| piece.position }
    elsif color == :black
      positions = black(pieces).map {|piece| piece.position }
    end
    positions
  end

  def move_piece(piece_position, move)
    selected_piece = @board[piece_position[0]][piece_position[1]]
    selected_piece.move(move)
  end
end

board = Board.new
game = Chess.new