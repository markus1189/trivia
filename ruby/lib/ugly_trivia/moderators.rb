require "stringio"
require "forwardable"

module UglyTrivia
  class GameModerator
    extend Forwardable
    def_delegator :@out, :puts

    def initialize(out=$stdout)
      @out = out
    end

    def wrong_answer(player)
  		puts 'Question was incorrectly answered'
  		puts "#{player} was sent to the penalty box"
    end

    def correct_answer(player)
      puts 'Answer was correct!'
      puts "#{player} now has #{player.coins} Gold coins."
    end

    def moved_player(player,location,category)
      puts "#{player}'s new location is: #{location}"
      puts "The category is #{category}"
    end

    def current_player(player)
      puts "#{player} is the current player"
    end

    def added_player(player,number)
      puts "#{player} was added as number #{number}."
    end

    def rolled(player,roll)
      puts "#{player} got a...#{roll}!"
    end

    def player_gets_out_of_penalty_box(player)
      puts "#{player} is getting out of the penalty box."
    end

    def player_stays_in_penalty_box(player)
      puts "#{player} is not getting out of the penalty box."
    end

    def announce_question(category)
      puts "Next question: '#{category}'"
    end

    def self.silent
      new(StringIO.new)
    end
  end

end
