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
end

class Board
  attr_reader :data, :winning_lines

  def initialize
    @data = {}
    (1..9).each{|pos| @data[pos] = Square.new(pos)}

    @winning_lines = [[1,2,3],[4,5,6],[7,8,9],[1,5,9],[7,5,3],[1,4,7],[2,5,8],[3,6,9]]
  end

  def display
    system 'clear'
    puts "         |         |        "
    puts "         |         |        "
    puts "    #{@data[1].value}    |    #{@data[2].value}    |    #{@data[3].value}    "
    puts "         |         |        "
    puts "         |         |        "
    puts "----------------------------" 
    puts "         |         |        "
    puts "         |         |        "
    puts "    #{@data[4].value}    |    #{@data[5].value}    |    #{@data[6].value}    "
    puts "         |         |        "
    puts "         |         |        "
    puts "----------------------------"
    puts "         |         |        "
    puts "         |         |        "
    puts "    #{@data[7].value}    |    #{@data[8].value}    |    #{@data[9].value}    "
    puts "         |         |        "
    puts "         |         |        "
  end

  def winner
    @winning_lines.each do |line|
      marker = @data[line[0]].value
      if marker.class != Fixnum
        return marker if marker == @data[line[1]].value && marker == @data[line[2]].value 
      end
    end 
    false
  end

  def empty_squares
    @data.select{|_,s| s.empty?}.keys
  end

  def full?
    empty_squares.size == 0
  end

  def mark(m)
    pos = m[0]
    marker = m[1]
    @data[pos].mark(marker)
  end 

end

class Player
  attr_reader :name, :marker

  def initialize(name = nil)
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
      answer = gets.chomp.upcase
    end until %w(X O).include?(answer)
    @marker = answer
  end 

  def marker=(m)
    @marker = m
  end

  def play_again?
    begin
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
    end until %w(y n).include?(answer)
    true if answer == 'y'
  end
end

class Game
  def initialize
    @board = Board.new
    @user = Player.new
    @computer = Player.new('CPU')
  end

  def welcome_user
    system 'clear'
    puts 'Welcome to Tic Tac Toe. Press enter to start'
    gets
  end

  def move(player)
    if player.name == 'CPU'
      possible_moves = []
      @board.winning_lines.each do |line|
        comp_squares = line.select{|sqr| @board.data[sqr].value == @computer.marker}
        empty_squares = line.select{|sqr| @board.data[sqr].value.class == Fixnum}
        user_squares = line.select{|sqr| @board.data[sqr].value.class == @user.marker}
        if empty_squares.length <= 3
          # win
          if comp_squares.length == 2 && empty_squares.length == 1
            possible_moves[0] = empty_squares.sample
            break
          # stop user from winning
          elsif user_squares.length == 2  && empty_squares.length == 1
            possible_moves[1] = empty_squares.sample
            break
          # second square in line
          elsif comp_squares.length == 1 && user_squares.length == 0
            possible_moves[2] = empty_squares.sample
          # block line for user
          elsif comp_squares.length == 0 && user_squares.length == 1
            possible_moves[3] = empty_squares.sample
          # place first square  
          else 
            possible_moves[4] = empty_squares.sample
          end
        end
      end
      possible_moves.each{|move| return [move, player.marker] if move.class == Fixnum}
    else
      begin 
        puts "Pick a square #{@board.empty_squares}:"
        move = gets.chomp.to_i
      end until @board.empty_squares.include?(move)
      return [move, player.marker]
    end
  end 

  def play 
    welcome_user
    @user.set_name
    @user.set_marker
    player1 = @user.marker == 'X' ? @user : @computer
    player2 = @user.name == player1.name ? @computer : @user
    @computer.marker = player1 == @computer ? 'X' : 'O'
    loop do 
      @board = Board.new
      @board.display
      loop do
        @board.mark(move(player1))
        @board.display
        break if @board.winner.class == String || @board.full?
        @board.mark(move(player2))
        @board.display
        break if @board.winner.class == String || @board.full?
      end
      display_winner
      break if !@user.play_again?
    end
  end

  def display_winner
    if !@board.winner
      puts "There was a tie."
    else
      winner = @user.marker == @board.winner ? @user : @computer
      puts "#{winner.name} wins!"
    end
  end
end

Game.new.play