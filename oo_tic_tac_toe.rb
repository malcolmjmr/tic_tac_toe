class Square
  attr_reader :value

  def initialize(pos)
    @value = pos
  end

  def mark(m)
    @value = m
  end 

  def empty?
    @value.class == Fixnum
  end

  def to_s
    @value
  end
end

class Board
  attr_reader :data, :WINNING_LINES

  def initialize
    @data = {}
    (1..9).each{|pos| @data = Square.new(pos)}

    @WINNING_LINES = [
      [1,2,3],
      [4,5,6],
      [7,8,9],
      [1,5,9],
      [7,5,3],
      [1,4,7],
      [2,5,8],
      [3,6,9]
    ]
  end

  def display(data)
    system 'clear'
    puts " #{@data[1]} | #{@data[2]} | #{@data[3]} "
    puts "-----------"
    puts " #{@data[4]} | #{@data[5]} | #{@data[6]} "
    puts "-----------"
    puts " #{@data[7]} | #{@data[8]} | #{@data[9]} "
  end

  def winner?
    WINNING_LINES.each do |line|
      marker = @data[line[0]].vlaue
      return marker if marker == @data[line[1]].value && marker == @data[line[2]].value 
    end 
  end

  def empty_squares
    @data.select {|k,s| s.empty?}.key
  end

  def full?
    empty_squares.size == 0
  end

  def mark(pos, player)
    @data[pos].mark(player.marker)
  end 

end

class Player
  attr_reader :name, :marker

  def initialize(name)
    @name = name
    @marker = nil
  end

  def set_name
    system 'clear'
    puts "What is your name?"
    @name = gets.chomp
  end

  def set_marker
    system 'clear'
    begin
      puts "Would you like to be X's or O's?"
      answer = gets.chomp.downcase
    end until %w(x o).include?(answer)
    @marker = answer
  end 

  def move(board)
    begin 
      puts "Choose a position #{board.empty_squares} to place a piece:"
      position = gets.chomp.to_i
    end until board.empty_positions.include?(position)
    position
  end

  def play_again?
    begin
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
    end until %w(y n).include(answer)
    true if answer == 'y'
  end
end

class Computer < Player
  def move(board)
    possible_moves = []
    board.WINNING_LINES.each do |line|
      comp_squares = line.select{|sqr| line[sqr].value == @marker }
      empty_squares = line.select{|sqr| line[sqr].value.class == Fixnum }
      user_squares = line.select{|sqr| line[sqr].value.class != Fixnum && line[sqr].value.class != @marker}
      if empty_squares.length < 3
        # win
        if comp_squares.length == 2 
          possible_moves[0] = empty_squares.sample
        # stop user from winning
        elsif user_squares.length == 2  
          possible_moves[1] = empty_squares.sample
        # second square in line
        elsif comp_squares.length == 1 && user_squares.length == 0
          possible_moves[2] = empty_squares.sample
        # block line for user
        elsif comp_squares.length == 0 && user_squares.length == 1
          possible_moves[3] = empty_squares.sample
        # place first square  
        elsif empty_squares.length == 3
          possible_moves[4] = empty_squares.sample
        end
      end
    end
    possible_moves.each{|move| return move if move.class == Fixnum}
  end
end

class Game
  def initialize
    @board = Board.new
    @user = Player.new(nil)
    @computer = Player.new('CPU')
  end

  def welcome_user
    system 'clear'
    puts 'Welcome to Tic Tac Toe. Press enter to start'
    gets
  end

  def play 
    welcome_user
    @user.set_name
    @user.set_marker
    player1 = @user.marker == 'X' ? @user : @computer
    player2 = @user == player1 ? @computer : @user
    loop do  
      loop do
        player1.move(@board)
        @board.display
        break if @board.winner != nil || @board.full?
        player2.move(@board)
        @board.display
        break if @board.winner != nil || @board.full?
      end
      display_winner
      break if !@user.play_again?
    end
  end

  def display_winner
    sytem 'clear'
    if @board.winner != nil
      winner = @user.marker == @board.winner ? @user : @computer
      puts "#{winner.name} wins!"
    else 
      puts "There was a tie."
    end
  end
end

Game.new.play