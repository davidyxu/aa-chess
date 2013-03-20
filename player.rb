class HumanPlayer
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
