# encoding: utf-8

require 'colorize'
require_relative './player'


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
    turn == :white ? @white.get_move : @black.get_move
  end

  def display_results(winner)
    puts "#{winner.capitalize} is the winner"
  end
end
