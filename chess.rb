require_relative './chess_pieces'
require_relative './board'
require_relative './interface'

class Chess
  def initialize
    @board = Board.new
    @interface = ChessInterface.new
    play
  end

  def play
    turn = :white
    until @board.game_over
      take_turn(turn)
      turn = @board.opposite_color(turn)
    end
    end_message
  end

  def take_turn(turn)
    begin
      @interface.print_check_message(turn) if @board.check?(turn)
      @interface.print_board(@board.board)
      move = @interface.get_move(turn)
    end until valid_move_selected?(move, turn)
      @board.move_piece(move[0], move[1])
  end

  def valid_move_selected?(move, turn)
    start_position = move[0]
    piece = @board[start_position]
    @board.piece_at_square?(move[0], turn) && piece.valid_moves.include?(move[1])
  end

  def end_message
    @interface.display_results(@board.game_over)
  end
end

board = Board.new
game = Chess.new