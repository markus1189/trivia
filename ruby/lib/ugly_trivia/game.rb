module UglyTrivia
  PlayerNotFoundError = Class.new(StandardError)
  class Game
    def  initialize
      @players = []
      @places = Array.new(6, 0)
      @purses = Array.new(6, 0)
      @in_penalty_box = Array.new(6) { false }
      
      @pop_questions = []
      @science_questions = []
      @sports_questions = []
      @rock_questions = []
      
      @current_player_index = 0
      @is_getting_out_of_penalty_box = false
      
      50.times do |i|
        @pop_questions.push "Pop Question #{i}"
        @science_questions.push "Science Question #{i}"
        @sports_questions.push "Sports Question #{i}"
        @rock_questions.push create_rock_question(i)
      end
    end

    def create_rock_question(index)
      "Rock Question #{index}"
    end

    def current_player
      @players.fetch(@current_player_index)
    end
    
    def playable?
      how_many_players >= 2
    end
    
    def add(player_name)
      @players.push player_name
      @places[how_many_players] = 0
      @purses[how_many_players] = 0
      
      puts "#{player_name} was added"
      puts "They are player number #{@players.length}"
      
      true
    end
    
    def how_many_players
      @players.length
    end

    def position_for_player(p)
      index = @players.index(p)
      @places.fetch(index)
    end

    def in_penalty_box?(p)
      index = @players.index(p) 
      index or raise PlayerNotFoundError
      @in_penalty_box.fetch(index)
    end

    def current_player_gets_out?
      @is_getting_out_of_penalty_box
    end
    
    def roll(roll)
      puts "#{@players[@current_player_index]} is the current player"
      puts "They have rolled a #{roll}"
      
      if in_penalty_box?(current_player)
        if roll % 2 != 0
          @is_getting_out_of_penalty_box = true

          puts "#{@players[@current_player_index]} is getting out of the penalty box"
          @places[@current_player_index] = @places[@current_player_index] + roll
          @places[@current_player_index] = @places[@current_player_index] - 12 if @places[@current_player_index] > 11
          
          puts @players[@current_player_index] +
                '\'s new location is' +
                @places[@current_player_index].to_s
          puts "The category is #{current_category}"
          ask_question
        else
          puts "#{@players[@current_player_index]} is not getting out of the penalty box"
          @is_getting_out_of_penalty_box = false
          end

      else

        @places[@current_player_index] = @places[@current_player_index] + roll
        @places[@current_player_index] = @places[@current_player_index] - 12 if @places[@current_player_index] > 11

        puts @players[@current_player_index] +
              '\'s new location is' +
              @places[@current_player_index].to_s
        puts "The category is #{current_category}"
        ask_question
      end
    end
    
  private
    
    def ask_question
      puts @pop_questions.shift if current_category == 'Pop'
      puts @science_questions.shift if current_category == 'Science'
      puts @sports_questions.shift if current_category == 'Sports'
      puts @rock_questions.shift if current_category == 'Rock'
    end
    
    def current_category
      return 'Pop' if @places[@current_player_index] == 0
      return 'Pop' if @places[@current_player_index] == 4
      return 'Pop' if @places[@current_player_index] == 8
      return 'Science' if @places[@current_player_index] == 1
      return 'Science' if @places[@current_player_index] == 5
      return 'Science' if @places[@current_player_index] == 9
      return 'Sports' if @places[@current_player_index] == 2
      return 'Sports' if @places[@current_player_index] == 6
      return 'Sports' if @places[@current_player_index] == 10
      return 'Rock'
    end
  
  public
  
    def was_correctly_answered
      if in_penalty_box?(current_player)
        if @is_getting_out_of_penalty_box
          puts 'Answer was correct!!!!'
          @purses[@current_player_index] += 1
          puts @players[@current_player_index] +
            ' now has ' +
            @purses[@current_player_index] +
            ' Gold Coins.'
          
          winner = did_player_win()
          @current_player_index += 1
          @current_player_index = 0 if @current_player_index == @players.length
          
          winner
        else
          @current_player_index += 1
          @current_player_index = 0 if @current_player_index == @players.length
          true
        end
        
        
        
      else
        
        puts "Answer was corrent!!!!"
        @purses[@current_player_index] += 1
        puts @players[@current_player_index] +
          ' now has ' +
          @purses[@current_player_index].to_s +
          ' Gold Coins.'
        
        winner = did_player_win
        @current_player_index += 1
        @current_player_index = 0 if @current_player_index == @players.length
        
        return winner
      end
    end
    
    def wrong_answer
  		puts 'Question was incorrectly answered'
  		puts @players[@current_player_index] + " was sent to the penalty box"
  		@in_penalty_box[@current_player_index] = true

      @current_player_index += 1
      @current_player_index = 0 if @current_player_index == @players.length
  		return true
    end
    
  private
  
    def did_player_win
      !(@purses[@current_player_index] == 6)
    end
  end
end
