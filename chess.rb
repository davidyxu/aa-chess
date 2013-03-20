# encoding: utf-8

require 'colorize'

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
      # REV: i like this
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
  def get_move(color)
    if color == :white
      @white.get_move
    else
      @black.get_move
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
    play
  end

  def play
    player = :black
    until @board.mate? or @board.draw?
      begin
        @interface.print_board(board)
        move = @interface.get_move(player)
        start_position = move[0]
        end_position = move[1]
        piece = board[start_position[0]][start_position[1]]
      end until @board.overlap_position?(move[0], player) && @board.overlap_position?(start_position, player) && piece.valid_moves.include?(move[1])
      start_position = move[0]
      end_position = move[1]
      @board.move_piece(start_position, end_position)
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
        # REV: this is confusing
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
=begin
    if color == :black
      pieces = @white
      king = @black.select { |piece| piece.is_a?(King) }
    elsif color == :white
      pieces = @black
      king = @white.select { |piece| piece.is_a?(King) }
    end
    valid_moves = pieces.inject([]) { |moves, piece| moves + piece.valid_moves }
    valid_moves.include?(king.position)
=end
    false
  end

  def preview_board(start_pos,end_pos)
    future_board = []
    @board.each { |row| future_board << row.dup }
    piece = @board[start_pos[0]][start_pos[1]]
    future_board[start_pos[0]][start_pos[1]] = nil
    future_board[end_pos[0]][end_pos[1]] = piece
    future_board
  end
  def draw?
    false
  end
  def mate?
    #return :black if false#if black checkmates
    #return :white if false#if white checkmates
    false
    #whether or not player of color has lost
  end
  #pieces
  #
  def overlap_position?(position, color)
    piece_positions(color).include?(position)
    # on the board
    # not on a current peice of the same color
    # follow the
  end
  def piece_positions(color)
    if color == :both
      combined = @board.white + @board.black
      positions = combined.map { |piece| piece.position }
    elsif color == :white
      positions = @white.map {|piece| piece.position }

    elsif color == :black
      positions = @black.map {|piece| piece.position }
    end
    positions
  end
  def move_piece(piece_position, move)
    selected_piece = @board[piece_position[0]][piece_position[1]]
    selected_piece.move(move)
  end
end

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
    # REV: i like how you delegated to methods here
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
    # REV: Haha, i know what you mean...
    # you could have:
    # valid_vectors = [[1,1], [-1,-1]...]
    # then do:
    # valid_vectors.each {|mv| valid_moves += moves_in_one_direction(mv)}
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
    # REV: where do you set @moved to true once the pawn moves?
    # your code looks like it devolved through the day
    # like ours!
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

board = Board.new
game = Chess.new