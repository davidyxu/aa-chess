
class Board
  attr_reader :board, :pieces

  def initialize(init = true)
    @pieces = []
    @board = Array.new(8) { Array.new(8) { nil } }
    initialize_board if init
  end

  def [](move)
    board[move[0]][move[1]]
  end
  def []=(move, piece)
    board[move[0]][move[1]] = piece

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

  def pieces_of(color, pieces = @pieces)
    pieces.select { |piece| piece.color == color}
  end

  def opposite_color (color)
    color == :white ? :black : :white
  end

  def check?(color, pieces = @pieces)
    enemy = pieces_of(opposite_color(color), pieces)
    king = pieces_of(color, pieces).select { |piece| piece.is_a?(King) }[0]

    enemy_moves = enemy.inject([]) { |moves, piece| moves + piece.possible_moves(pieces) }
    enemy_moves.include?(king.position)
  end

  def preview_move(start_pos,end_pos, color)
    preview = dup
    piece = preview.pieces.select { |piece| piece.position == start_pos }[0]
    piece.move(end_pos)
    check(color)
  end

  def game_over
    return :white if mate?(:black)
    return :black if mate?(:white)
    false
  end

  def move_set(color, pieces = @pieces)
    pieces_of(color, pieces).inject([]) { |moves, piece| moves + piece.valid_moves }
  end

  def mate?(color)
    return :black if move_set(:black).empty?
    return :white if move_set(:white).empty?
    false
  end

  def piece_at_square?(position, color, pieces = @pieces)
    piece_positions(color, pieces).include?(position)
  end

  def piece_positions(color, pieces)
    if color == :both
      pieces.map { |piece| piece.position }
    else
      pieces_of(color, pieces).map {|piece| piece.position }
    end
  end

  def move_piece(piece_position, move)
    selected_piece = self[piece_position]
    selected_piece.move(move)
  end

  def remove_piece_at(position)
    pieces.reject! {|piece| piece == [position]}
  end

  private
  def dup
    duped_board = Board.new(false)
    @board.each_with_index do |row, row_index|
      row.each_with_index do |square, col_index|
        duped_board.add_piece(self[[row_index, col_index]].dup)
      end
    end
    duped_board
  end
  def add_piece(piece)
    @pieces << piece
    duped_board[row_index,col_index] = piece
  end
end